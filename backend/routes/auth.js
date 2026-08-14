/**
 * ===========================================
 * Arthings - Authentication Routes
 * ===========================================
 *
 * Registration, login and profile management.
 */

const express = require('express');
const bcrypt = require('bcryptjs');
const prisma = require('../db/db');
const { validate } = require('../middleware/validate');
const { limiters } = require('../middleware/security');
const { requireAuth } = require('../middleware/auth');
const schemas = require('../validators/auth');

const router = express.Router();

/** Public shape of a user. Never includes the password hash. */
function formatUser(user) {
    return {
        id: `user-${user.id}`,
        email: user.email,
        name: user.name,
        phone: user.phone,
        city: user.city,
        avatar: user.avatar,
        isVerified: user.isVerified,
        isAdmin: user.isAdmin,
        rating: Number(user.ratingAvg ?? 0),
        ratingCount: user.ratingCount ?? 0,
        createdAt: user.createdAt
    };
}

/**
 * Establishes a logged-in session.
 *
 * The session id is regenerated first: without this, a session token an
 * attacker planted before login would stay valid afterwards (session
 * fixation). The explicit save() matters on serverless, where the response
 * can otherwise race the session write to Postgres.
 */
function startSession(req, user) {
    return new Promise((resolve, reject) => {
        req.session.regenerate(error => {
            if (error) return reject(error);
            req.session.userId = user.id;
            req.session.userEmail = user.email;
            req.session.save(saveError => (saveError ? reject(saveError) : resolve()));
        });
    });
}

// ---------------------------------------------------------------------------
// Registration & login
// ---------------------------------------------------------------------------

/**
 * POST /api/auth/register
 * Creates an account and signs the user straight in.
 */
router.post('/register', limiters.auth, validate({ body: schemas.register }), async (req, res) => {
    try {
        const { email, password, name, phone, city, consents } = req.body;

        const existing = await prisma.user.findUnique({
            where: { email },
            select: { id: true }
        });

        if (existing) {
            return res.status(409).json({ error: 'An account with this email already exists' });
        }

        const passwordHash = await bcrypt.hash(password, 10);

        const user = await prisma.$transaction(async tx => {
            const created = await tx.user.create({
                data: {
                    email,
                    passwordHash,
                    name: name || email.split('@')[0],
                    phone: phone || null,
                    city: city || null,
                    avatar: null,
                    isVerified: false
                }
            });

            if (consents?.length) {
                await tx.legalConsent.createMany({
                    data: consents.map(item => ({
                        userId: created.id,
                        documentType: item.type,
                        documentVersion: item.version,
                        ipAddress: req.ip || null,
                        userAgent: req.get('User-Agent')?.slice(0, 500) || null
                    }))
                });
            }

            return created;
        });

        await startSession(req, user);

        res.status(201).json({
            message: 'Registration successful',
            user: formatUser(user)
        });
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ error: 'Registration failed' });
    }
});

router.post('/login', limiters.auth, validate({ body: schemas.login }), async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await prisma.user.findUnique({ where: { email } });

        // Compare against a dummy hash when the user is absent so response
        // timing does not reveal whether the address is registered.
        const hash = user
            ? user.passwordHash
            : '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy';
        const matches = await bcrypt.compare(password, hash);

        if (!user || !matches) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        await startSession(req, user);
        res.json({ message: 'Login successful', user: formatUser(user) });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ error: 'Login failed' });
    }
});

router.post('/logout', (req, res) => {
    req.session.destroy(error => {
        if (error) return res.status(500).json({ error: 'Logout failed' });
        res.clearCookie('connect.sid');
        res.json({ message: 'Logged out successfully' });
    });
});

// ---------------------------------------------------------------------------
// Profile
// ---------------------------------------------------------------------------

router.get('/me', async (req, res) => {
    if (!req.session.userId) {
        return res.status(401).json({ error: 'Not authenticated' });
    }

    try {
        const user = await prisma.user.findUnique({ where: { id: req.session.userId } });
        if (!user) {
            // Session outlived the account.
            return req.session.destroy(() => res.status(401).json({ error: 'Not authenticated' }));
        }
        res.json({ user: formatUser(user) });
    } catch (error) {
        console.error('Get user error:', error);
        res.status(500).json({ error: 'Failed to get user' });
    }
});

router.put('/profile', requireAuth, validate({ body: schemas.updateProfile }), async (req, res) => {
    try {
        const { name, phone, city } = req.body;

        const user = await prisma.user.update({
            where: { id: req.session.userId },
            data: {
                ...(name !== undefined && { name }),
                ...(phone !== undefined && { phone: phone || null }),
                ...(city !== undefined && { city: city || null })
            }
        });

        res.json({ message: 'Profile updated', user: formatUser(user) });
    } catch (error) {
        console.error('Profile update error:', error);
        res.status(500).json({ error: 'Profile update failed' });
    }
});

router.post('/change-password', requireAuth, validate({ body: schemas.changePassword }), async (req, res) => {
    try {
        const user = await prisma.user.findUnique({ where: { id: req.session.userId } });
        const matches = await bcrypt.compare(req.body.currentPassword, user.passwordHash);
        if (!matches) {
            return res.status(400).json({ error: 'Current password is incorrect' });
        }

        await prisma.user.update({
            where: { id: user.id },
            data: { passwordHash: await bcrypt.hash(req.body.newPassword, 10) }
        });

        res.json({ message: 'Password updated' });
    } catch (error) {
        console.error('Change password error:', error);
        res.status(500).json({ error: 'Could not change password' });
    }
});

/**
 * DELETE /api/auth/account
 * Requires the current password — a stolen session alone must not be enough
 * to destroy an account and every listing attached to it.
 */
router.delete('/account', requireAuth, async (req, res) => {
    try {
        const password = req.body?.password;
        if (!password) {
            return res.status(400).json({ error: 'Password confirmation is required' });
        }

        const user = await prisma.user.findUnique({ where: { id: req.session.userId } });
        const matches = await bcrypt.compare(String(password), user.passwordHash);
        if (!matches) {
            return res.status(403).json({ error: 'Password is incorrect' });
        }

        await prisma.user.delete({ where: { id: user.id } });
        req.session.destroy(() => {});
        res.json({ message: 'Account deleted successfully' });
    } catch (error) {
        console.error('Account deletion error:', error);
        res.status(500).json({ error: 'Failed to delete account' });
    }
});

module.exports = router;
// Shared with other routes that need to serialise a user consistently.
module.exports.formatUser = formatUser;

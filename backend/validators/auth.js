/**
 * Validation schemas for authentication endpoints.
 */

const { z } = require('zod');
const { email, password, optionalText, requiredText } = require('./common');

const consent = z.object({
    type: z.string().max(50),
    version: z.string().max(20)
});

const register = z.object({
    email,
    password,
    name: optionalText(255),
    phone: optionalText(50),
    city: optionalText(100),
    consents: z.array(consent).max(10).optional()
});

const login = z.object({
    email,
    // Deliberately not the strict `password` schema: rejecting a short
    // password at validation time would reveal the policy and return a
    // different response shape than a normal failed login.
    password: z.string().min(1, 'Password is required').max(200)
});

const changePassword = z.object({
    currentPassword: z.string().min(1, 'Current password is required').max(200),
    newPassword: password
});

const updateProfile = z.object({
    name: requiredText(1, 255, 'Name').optional(),
    phone: optionalText(50),
    city: optionalText(100)
});

module.exports = {
    register,
    login,
    changePassword,
    updateProfile
};

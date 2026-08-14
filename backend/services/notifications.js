/**
 * ===========================================
 * Arthings - Notification Service
 * ===========================================
 *
 * Writes the in-app notification feed.
 *
 * Delivery is deliberately best-effort: a failed notification must never roll
 * back the action that produced it. Accepting a rental request that then fails
 * to notify is a missing notification, not a failed acceptance.
 */

const prisma = require('../db/db');
const config = require('../config/env');

/**
 * Records an in-app notification.
 *
 * @param {object} params
 * @param {number} params.userId  recipient
 * @param {string} params.type    NotificationType enum value
 * @param {string} params.title
 * @param {string} [params.body]
 * @param {string} [params.link]  relative in-app path
 */
async function notify({ userId, type, title, body, link }) {
    try {
        return await prisma.notification.create({
            data: {
                userId,
                type,
                title: title.slice(0, 255),
                body: body ?? null,
                link: link ?? null
            }
        });
    } catch (error) {
        console.error('Failed to record notification:', error.message);
        return null;
    }
}

/** Absolute URL, for links that need to work outside the app shell. */
function absoluteUrl(path) {
    return `${config.appUrl}${path.startsWith('/') ? path : `/${path}`}`;
}

/** Unread count for the header badge. */
async function unreadCount(userId) {
    return prisma.notification.count({ where: { userId, readAt: null } });
}

module.exports = { notify, absoluteUrl, unreadCount };

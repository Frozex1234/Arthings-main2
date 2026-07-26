/**
 * ===========================================
 * Arthings - Simple chat routes
 * ===========================================
 */

const express = require('express');
const prisma = require('../db/db');

const router = express.Router();
const messages = [];

router.get('/messages', async (req, res) => {
    try {
        if (!req.session.userId) {
            return res.status(401).json({ error: 'Authentication required' });
        }

        const user = await prisma.user.findUnique({
            where: { id: req.session.userId },
            select: { id: true, name: true }
        });

        const formattedMessages = messages.map((message) => ({
            id: message.id,
            text: message.text,
            userId: `user-${message.userId}`,
            userName: message.userName,
            createdAt: message.createdAt,
            isMine: message.userId === req.session.userId
        }));

        res.json({
            messages: formattedMessages,
            user: user ? { id: `user-${user.id}`, name: user.name } : null
        });
    } catch (error) {
        console.error('Get chat messages error:', error);
        res.status(500).json({ error: 'Failed to load chat' });
    }
});

router.post('/messages', async (req, res) => {
    try {
        if (!req.session.userId) {
            return res.status(401).json({ error: 'Authentication required' });
        }

        const { text } = req.body;
        if (!text || !text.trim()) {
            return res.status(400).json({ error: 'Message text is required' });
        }

        const user = await prisma.user.findUnique({
            where: { id: req.session.userId },
            select: { id: true, name: true }
        });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        const newMessage = {
            id: `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
            userId: user.id,
            userName: user.name,
            text: text.trim(),
            createdAt: new Date().toISOString()
        };

        messages.push(newMessage);
        if (messages.length > 100) {
            messages.splice(0, messages.length - 100);
        }

        res.status(201).json({ message: newMessage });
    } catch (error) {
        console.error('Create chat message error:', error);
        res.status(500).json({ error: 'Failed to send message' });
    }
});

module.exports = router;

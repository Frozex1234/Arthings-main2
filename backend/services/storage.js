/**
 * ===========================================
 * Arthings - Upload Storage
 * ===========================================
 *
 * Abstracts where listing photos live.
 *
 *   cloudinary — CDN-backed, with server-side resizing. The production driver.
 *   blob       — Vercel Blob, an alternative for serverless deployments.
 *   local      — writes to ./uploads. Fine on a VM or during development.
 *
 * Serverless platforms have an ephemeral, per-invocation filesystem: anything
 * written to disk disappears on the next request and is invisible to other
 * instances. So `local` is a development-only driver.
 *
 * Routes call `persistFiles()` and receive public URLs; they never care which
 * driver is active.
 */

const multer = require('multer');
const path = require('path');
const fs = require('fs');
const fsp = require('fs/promises');
const { v4: uuidv4 } = require('uuid');
const config = require('../config/env');

const UPLOAD_DIR = path.join(__dirname, '../../uploads');
const ALLOWED_MIME = new Set(['image/jpeg', 'image/png', 'image/gif', 'image/webp']);

const driver = config.storage.driver;
const isBlob = driver === 'blob';
const isCloudinary = driver === 'cloudinary';

/**
 * Builds the multer storage engine for the active driver.
 *
 *   cloudinary — uploads during multer's own pass, so the file never touches
 *                local disk and arrives already resized.
 *   blob       — needs the body in hand, so buffers in memory.
 *   local      — streams straight to disk to keep peak memory flat.
 */
function createStorageEngine() {
    if (isCloudinary) {
        const { CloudinaryStorage } = require('multer-storage-cloudinary');
        const { cloudinary } = require('../config/cloudinary');

        return new CloudinaryStorage({
            cloudinary,
            params: {
                folder: 'arthings',
                // Caps stored dimensions so a 12MP phone photo does not become
                // a 12MP download for every visitor browsing the map.
                transformation: [
                    { width: 1200, height: 1200, crop: 'limit', quality: 'auto' }
                ],
                public_id: () => `item-${uuidv4()}`
            }
        });
    }

    if (isBlob) return multer.memoryStorage();

    return multer.diskStorage({
        destination: (req, file, cb) => {
            fs.mkdirSync(UPLOAD_DIR, { recursive: true });
            cb(null, UPLOAD_DIR);
        },
        filename: (req, file, cb) => {
            cb(null, uuidv4() + path.extname(file.originalname).toLowerCase());
        }
    });
}

const storage = createStorageEngine();

/**
 * Multer instance shared by every upload route.
 *
 * Note the extension is derived from the *mimetype*, never from the client's
 * filename, so a `.php`/`.svg` name cannot ride along with an image mimetype.
 */
const uploader = multer({
    storage,
    limits: {
        fileSize: config.storage.maxFileBytes,
        files: config.storage.maxFilesPerListing
    },
    fileFilter: (req, file, cb) => {
        if (ALLOWED_MIME.has(file.mimetype)) return cb(null, true);
        const error = new Error('Only JPEG, PNG, GIF and WebP images are allowed.');
        error.code = 'INVALID_FILE_TYPE';
        cb(error);
    }
});

function extensionFor(mimetype) {
    switch (mimetype) {
        case 'image/png': return '.png';
        case 'image/gif': return '.gif';
        case 'image/webp': return '.webp';
        default: return '.jpg';
    }
}

/**
 * Recovers a Cloudinary public_id from a delivery URL.
 *
 * URLs look like:
 *   https://res.cloudinary.com/<cloud>/image/upload/v1699/arthings/item-uuid.jpg
 *
 * The public_id is everything after the (optional) version segment, minus the
 * extension — folder included, since the asset lives under `arthings/`.
 *
 * @param {string} url
 * @returns {string|null}
 */
function cloudinaryPublicId(url) {
    const marker = '/upload/';
    const index = url.indexOf(marker);
    if (index === -1) return null;

    let remainder = url.slice(index + marker.length);

    // Drop transformation and version segments (e.g. `w_200/`, `v1699.../`).
    const segments = remainder.split('/');
    while (segments.length > 1 && /^(v\d+|[a-z]{1,3}_[^/]+)$/.test(segments[0])) {
        segments.shift();
    }
    remainder = segments.join('/');

    // Strip the extension, keeping any dots inside the name itself.
    const lastDot = remainder.lastIndexOf('.');
    return lastDot > 0 ? remainder.slice(0, lastDot) : remainder || null;
}

let blobClient = null;
function getBlobClient() {
    if (blobClient) return blobClient;
    try {
        // Lazily required so a local install without the package still boots.
        blobClient = require('@vercel/blob');
    } catch {
        throw new Error(
            'STORAGE_DRIVER=blob requires the @vercel/blob package. ' +
            'Run: npm install @vercel/blob'
        );
    }
    return blobClient;
}

/**
 * Persists uploaded files and returns their public URLs, in input order.
 *
 * @param {Array} files - multer file objects
 * @returns {Promise<string[]>}
 */
async function persistFiles(files) {
    if (!files || files.length === 0) return [];

    if (isCloudinary) {
        // CloudinaryStorage uploaded during multer's pass and exposes the
        // resulting secure URL on `path`.
        return files.map(file => file.path);
    }

    if (!isBlob) {
        // diskStorage already wrote them; just map to their public path.
        return files.map(file => `/uploads/${file.filename}`);
    }

    const { put } = getBlobClient();
    return Promise.all(
        files.map(async file => {
            const key = `listings/${uuidv4()}${extensionFor(file.mimetype)}`;
            const result = await put(key, file.buffer, {
                access: 'public',
                contentType: file.mimetype,
                token: config.storage.blobToken
            });
            return result.url;
        })
    );
}

/**
 * Best-effort removal of a previously stored file.
 * Never throws: a failed cleanup must not fail the user's delete request.
 *
 * @param {string} url - value previously returned by persistFiles()
 */
async function deleteFile(url) {
    if (!url) return;

    try {
        if (url.startsWith('/uploads/')) {
            const filename = path.basename(url);
            // Guard against traversal via a crafted stored path.
            const target = path.join(UPLOAD_DIR, filename);
            if (!target.startsWith(UPLOAD_DIR)) return;
            await fsp.unlink(target).catch(() => {});
            return;
        }

        if (isCloudinary && url.includes('/upload/')) {
            const { cloudinary } = require('../config/cloudinary');
            const publicId = cloudinaryPublicId(url);
            if (publicId) await cloudinary.uploader.destroy(publicId);
            return;
        }

        if (isBlob && url.startsWith('http')) {
            const { del } = getBlobClient();
            await del(url, { token: config.storage.blobToken });
        }
    } catch (error) {
        console.error('Storage cleanup failed:', url, error.message);
    }
}

/**
 * Translates multer's errors into user-facing messages.
 * Without this, an oversized upload surfaces as a generic 500.
 */
function handleUploadError(error, req, res, next) {
    if (error instanceof multer.MulterError) {
        const messages = {
            LIMIT_FILE_SIZE: `Each image must be ${Math.round(config.storage.maxFileBytes / (1024 * 1024))}MB or smaller.`,
            LIMIT_FILE_COUNT: `You can upload at most ${config.storage.maxFilesPerListing} images.`,
            LIMIT_UNEXPECTED_FILE: 'Unexpected file field.'
        };
        return res.status(400).json({
            error: messages[error.code] || 'Upload failed.',
            code: error.code
        });
    }

    if (error && error.code === 'INVALID_FILE_TYPE') {
        return res.status(400).json({ error: error.message, code: error.code });
    }

    next(error);
}

module.exports = {
    uploader,
    persistFiles,
    deleteFile,
    handleUploadError,
    UPLOAD_DIR
};

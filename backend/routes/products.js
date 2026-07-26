/**
 * ===========================================
 * Arthings - Products/Items Routes
 * ===========================================
 * 
 * Handles CRUD operations for rentable items
 */

const express = require('express');
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const prisma = require('../db/db');
const { cloudinary } = require('../config/cloudinary');
const { CloudinaryStorage } = require('multer-storage-cloudinary');

const router = express.Router();

// Cloudinary storage for image uploads (persistent, CDN-backed)
const storage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: {
        folder: 'arthings',
        allowed_formats: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        transformation: [{ width: 1200, height: 1200, crop: 'limit', quality: 'auto' }],
        public_id: (req, file) => `item-${uuidv4()}`
    }
});

const upload = multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
    fileFilter: (req, file, cb) => {
        const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        if (allowedTypes.includes(file.mimetype)) {
            cb(null, true);
        } else {
            cb(new Error('Invalid file type. Only JPEG, PNG, GIF, and WebP are allowed.'));
        }
    }
});

/**
 * GET /api/products
 * Get all products with optional filtering
 */
router.get('/', async (req, res) => {
    try {
        const {
            search,
            category,
            minPrice,
            maxPrice,
            available,
            city,
            userId,
            sort,
            listingType,
            propertyType,
            bedrooms,
            bathrooms,
            areaSqm,
            furnished,
            petFriendly,
            studentFriendly,
            moveInDate,
            address
        } = req.query;

        // Build where clause
        const where = {};

        // Filter by search query (title and description)
        if (search) {
            where.OR = [
                { title: { contains: search } },
                { description: { contains: search } }
            ];
        }

        // Filter by category
        if (category) {
            where.category = category;
        }

        // Filter by price range
        if (minPrice || maxPrice) {
            where.pricePerDay = {};
            if (minPrice) where.pricePerDay.gte = parseFloat(minPrice);
            if (maxPrice) where.pricePerDay.lte = parseFloat(maxPrice);
        }

        // Filter by availability
        if (available !== undefined) {
            where.isAvailable = available === 'true';
        }

        // Filter by city
        if (city) {
            where.city = { equals: city, mode: 'insensitive' };
        }

        if (listingType) {
            where.listingType = listingType;
        }

        if (propertyType) {
            where.propertyType = propertyType;
        }

        if (bedrooms) {
            where.bedrooms = { gte: parseInt(bedrooms) };
        }

        if (bathrooms) {
            where.bathrooms = { gte: parseInt(bathrooms) };
        }

        if (areaSqm) {
            where.areaSqm = { gte: parseInt(areaSqm) };
        }

        if (furnished !== undefined) {
            where.furnished = furnished === 'true';
        }

        if (petFriendly !== undefined) {
            where.petFriendly = petFriendly === 'true';
        }

        if (studentFriendly !== undefined) {
            where.studentFriendly = studentFriendly === 'true';
        }

        if (moveInDate) {
            where.moveInDate = { contains: moveInDate };
        }

        if (address) {
            where.address = { contains: address, mode: 'insensitive' };
        }

        // Filter by user (for my-listings)
        if (userId) {
            // Handle both "user-123" format and numeric ID
            const numericId = userId.startsWith('user-')
                ? parseInt(userId.replace('user-', ''))
                : parseInt(userId);
            if (!isNaN(numericId)) {
                where.userId = numericId;
            }
        }

        // Build orderBy
        let orderBy = { createdAt: 'desc' }; // Default: newest first
        if (sort) {
            switch (sort) {
                case 'price-asc':
                    orderBy = { pricePerDay: 'asc' };
                    break;
                case 'price-desc':
                    orderBy = { pricePerDay: 'desc' };
                    break;
                case 'newest':
                    orderBy = { createdAt: 'desc' };
                    break;
                case 'popular':
                    orderBy = { views: 'desc' };
                    break;
            }
        }

        // Fetch products with relations
        const products = await prisma.item.findMany({
            where,
            orderBy,
            include: {
                user: {
                    select: { id: true, name: true, city: true }
                },
                images: {
                    orderBy: { sortOrder: 'asc' }
                }
            }
        });

        // Transform to match expected format
        const formattedProducts = products.map(p => ({
            id: `prod-${p.id}`,
            userId: `user-${p.userId}`,
            title: p.title,
            description: p.description,
            category: p.category,
            price: Number(p.pricePerDay),
            priceUnit: p.priceUnit,
            city: p.city,
            available: p.isAvailable,
            images: p.images.map(img => img.imagePath),
            views: p.views,
            createdAt: p.createdAt.toISOString(),
            ownerName: p.user?.name || 'Unknown',
            ownerCity: p.user?.city || '',
            listingType: p.listingType || null,
            propertyType: p.propertyType || null,
            bedrooms: p.bedrooms || null,
            bathrooms: p.bathrooms || null,
            areaSqm: p.areaSqm || null,
            furnished: p.furnished || false,
            petFriendly: p.petFriendly || false,
            studentFriendly: p.studentFriendly || false,
            moveInDate: p.moveInDate || null,
            address: p.address || null
        }));

        res.json({ products: formattedProducts, total: formattedProducts.length });

    } catch (error) {
        console.error('Get products error:', error);
        res.status(500).json({ error: 'Failed to get products' });
    }
});

/**
 * GET /api/products/:id
 * Get single product by ID
 */
router.get('/:id', async (req, res) => {
    try {
        // Handle both "prod-123" format and numeric ID
        const idParam = req.params.id;
        const numericId = idParam.startsWith('prod-')
            ? parseInt(idParam.replace('prod-', ''))
            : parseInt(idParam);

        if (isNaN(numericId)) {
            return res.status(400).json({ error: 'Invalid product ID' });
        }

        const product = await prisma.item.findUnique({
            where: { id: numericId },
            include: {
                user: {
                    select: { id: true, name: true, city: true, phone: true }
                },
                images: {
                    orderBy: { sortOrder: 'asc' }
                }
            }
        });

        if (!product) {
            return res.status(404).json({ error: 'Product not found' });
        }

        // Increment view count
        await prisma.item.update({
            where: { id: numericId },
            data: { views: { increment: 1 } }
        });

        res.json({
            product: {
                id: `prod-${product.id}`,
                userId: `user-${product.userId}`,
                title: product.title,
                description: product.description,
                category: product.category,
                price: Number(product.pricePerDay),
                priceUnit: product.priceUnit,
                city: product.city,
                available: product.isAvailable,
                images: product.images.map(img => img.imagePath),
                views: product.views + 1,
                listingType: product.listingType || null,
                propertyType: product.propertyType || null,
                bedrooms: product.bedrooms || null,
                bathrooms: product.bathrooms || null,
                areaSqm: product.areaSqm || null,
                furnished: product.furnished || false,
                petFriendly: product.petFriendly || false,
                studentFriendly: product.studentFriendly || false,
                moveInDate: product.moveInDate || null,
                address: product.address || null,
                createdAt: product.createdAt.toISOString(),
                ownerName: product.user?.name || 'Unknown',
                ownerCity: product.user?.city || '',
                ownerPhone: product.user?.phone || ''
            }
        });

    } catch (error) {
        console.error('Get product error:', error);
        res.status(500).json({ error: 'Failed to get product' });
    }
});

/**
 * POST /api/products
 * Create new product (authenticated)
 */
router.post('/', upload.array('images', 5), async (req, res) => {
    try {
        if (!req.session.userId) {
            return res.status(401).json({ error: 'Authentication required' });
        }

        const {
            title,
            description,
            category,
            price,
            priceUnit,
            city,
            listingType,
            propertyType,
            bedrooms,
            bathrooms,
            areaSqm,
            furnished,
            petFriendly,
            studentFriendly,
            moveInDate,
            address
        } = req.body;

        // Validation
        if (!title || !description || !category || !price) {
            return res.status(400).json({ error: 'Title, description, category, and price are required' });
        }

        // Create product with images in a transaction
        const newProduct = await prisma.$transaction(async (tx) => {
            // Create product
            const product = await tx.item.create({
                data: {
                    userId: req.session.userId,
                    title,
                    description,
                    pricePerDay: parseFloat(price),
                    priceUnit: priceUnit || 'day',
                    category,
                    city: city || null,
                    listingType: listingType || null,
                    propertyType: propertyType || null,
                    bedrooms: bedrooms ? parseInt(bedrooms) : null,
                    bathrooms: bathrooms ? parseInt(bathrooms) : null,
                    areaSqm: areaSqm ? parseInt(areaSqm) : null,
                    furnished: furnished === 'true' || furnished === true,
                    petFriendly: petFriendly === 'true' || petFriendly === true,
                    studentFriendly: studentFriendly === 'true' || studentFriendly === true,
                    moveInDate: moveInDate || null,
                    address: address || null,
                    isAvailable: true,
                    views: 0
                }
            });

            // Create image records
            if (req.files && req.files.length > 0) {
                for (let i = 0; i < req.files.length; i++) {
                    await tx.itemImage.create({
                        data: {
                            itemId: product.id,
                            imagePath: req.files[i].path,
                            sortOrder: i
                        }
                    });
                }
            }

            return product;
        });

        // Fetch complete product with images
        const productWithImages = await prisma.item.findUnique({
            where: { id: newProduct.id },
            include: { images: { orderBy: { sortOrder: 'asc' } } }
        });

        res.status(201).json({
            message: 'Product created successfully',
            product: {
                id: `prod-${productWithImages.id}`,
                userId: `user-${productWithImages.userId}`,
                title: productWithImages.title,
                description: productWithImages.description,
                category: productWithImages.category,
                price: Number(productWithImages.pricePerDay),
                priceUnit: productWithImages.priceUnit,
                city: productWithImages.city,
                available: productWithImages.isAvailable,
                images: productWithImages.images.map(img => img.imagePath),
                views: productWithImages.views,
                listingType: productWithImages.listingType,
                propertyType: productWithImages.propertyType,
                bedrooms: productWithImages.bedrooms,
                bathrooms: productWithImages.bathrooms,
                areaSqm: productWithImages.areaSqm,
                furnished: productWithImages.furnished,
                petFriendly: productWithImages.petFriendly,
                studentFriendly: productWithImages.studentFriendly,
                moveInDate: productWithImages.moveInDate,
                address: productWithImages.address,
                createdAt: productWithImages.createdAt.toISOString()
            }
        });

    } catch (error) {
        console.error('Create product error:', error);
        res.status(500).json({ error: 'Failed to create product' });
    }
});

/**
 * PUT /api/products/:id
 * Update product (owner only)
 */
router.put('/:id', upload.array('images', 5), async (req, res) => {
    try {
        if (!req.session.userId) {
            return res.status(401).json({ error: 'Authentication required' });
        }

        // Parse ID
        const idParam = req.params.id;
        const numericId = idParam.startsWith('prod-')
            ? parseInt(idParam.replace('prod-', ''))
            : parseInt(idParam);

        if (isNaN(numericId)) {
            return res.status(400).json({ error: 'Invalid product ID' });
        }

        // Check ownership
        const existingProduct = await prisma.item.findUnique({
            where: { id: numericId }
        });

        if (!existingProduct) {
            return res.status(404).json({ error: 'Product not found' });
        }

        if (existingProduct.userId !== req.session.userId) {
            return res.status(403).json({ error: 'You can only edit your own products' });
        }

        const {
            title,
            description,
            category,
            price,
            priceUnit,
            city,
            available,
            listingType,
            propertyType,
            bedrooms,
            bathrooms,
            areaSqm,
            furnished,
            petFriendly,
            studentFriendly,
            moveInDate,
            address
        } = req.body;

        // Update product with images in a transaction
        const updatedProduct = await prisma.$transaction(async (tx) => {
            // Update product fields
            const product = await tx.item.update({
                where: { id: numericId },
                data: {
                    ...(title && { title }),
                    ...(description && { description }),
                    ...(category && { category }),
                    ...(price && { pricePerDay: parseFloat(price) }),
                    ...(priceUnit && { priceUnit }),
                    ...(city !== undefined && { city: city || null }),
                    ...(listingType !== undefined && { listingType: listingType || null }),
                    ...(propertyType !== undefined && { propertyType: propertyType || null }),
                    ...(bedrooms !== undefined && { bedrooms: bedrooms ? parseInt(bedrooms) : null }),
                    ...(bathrooms !== undefined && { bathrooms: bathrooms ? parseInt(bathrooms) : null }),
                    ...(areaSqm !== undefined && { areaSqm: areaSqm ? parseInt(areaSqm) : null }),
                    ...(furnished !== undefined && { furnished: furnished === 'true' || furnished === true }),
                    ...(petFriendly !== undefined && { petFriendly: petFriendly === 'true' || petFriendly === true }),
                    ...(studentFriendly !== undefined && { studentFriendly: studentFriendly === 'true' || studentFriendly === true }),
                    ...(moveInDate !== undefined && { moveInDate: moveInDate || null }),
                    ...(address !== undefined && { address: address || null }),
                    ...(available !== undefined && { isAvailable: available === 'true' || available === true })
                }
            });

            // Add new images if uploaded
            if (req.files && req.files.length > 0) {
                // Get current max sort order
                const lastImage = await tx.itemImage.findFirst({
                    where: { itemId: numericId },
                    orderBy: { sortOrder: 'desc' }
                });
                const startOrder = lastImage ? lastImage.sortOrder + 1 : 0;

                for (let i = 0; i < req.files.length; i++) {
                    await tx.itemImage.create({
                        data: {
                            itemId: product.id,
                            imagePath: req.files[i].path,
                            sortOrder: startOrder + i
                        }
                    });
                }
            }

            return product;
        });

        // Fetch complete product with images
        const productWithImages = await prisma.item.findUnique({
            where: { id: updatedProduct.id },
            include: { images: { orderBy: { sortOrder: 'asc' } } }
        });

        res.json({
            message: 'Product updated successfully',
            product: {
                id: `prod-${productWithImages.id}`,
                userId: `user-${productWithImages.userId}`,
                title: productWithImages.title,
                description: productWithImages.description,
                category: productWithImages.category,
                price: Number(productWithImages.pricePerDay),
                priceUnit: productWithImages.priceUnit,
                city: productWithImages.city,
                available: productWithImages.isAvailable,
                images: productWithImages.images.map(img => img.imagePath),
                views: productWithImages.views,
                listingType: productWithImages.listingType,
                propertyType: productWithImages.propertyType,
                bedrooms: productWithImages.bedrooms,
                bathrooms: productWithImages.bathrooms,
                areaSqm: productWithImages.areaSqm,
                furnished: productWithImages.furnished,
                petFriendly: productWithImages.petFriendly,
                studentFriendly: productWithImages.studentFriendly,
                moveInDate: productWithImages.moveInDate,
                address: productWithImages.address,
                createdAt: productWithImages.createdAt.toISOString()
            }
        });

    } catch (error) {
        console.error('Update product error:', error);
        res.status(500).json({ error: 'Failed to update product' });
    }
});

/**
 * DELETE /api/products/:id
 * Delete product (owner only)
 */
router.delete('/:id', async (req, res) => {
    try {
        if (!req.session.userId) {
            return res.status(401).json({ error: 'Authentication required' });
        }

        // Parse ID
        const idParam = req.params.id;
        const numericId = idParam.startsWith('prod-')
            ? parseInt(idParam.replace('prod-', ''))
            : parseInt(idParam);

        if (isNaN(numericId)) {
            return res.status(400).json({ error: 'Invalid product ID' });
        }

        // Fetch product with images
        const product = await prisma.item.findUnique({
            where: { id: numericId },
            include: { images: true }
        });

        if (!product) {
            return res.status(404).json({ error: 'Product not found' });
        }

        if (product.userId !== req.session.userId) {
            return res.status(403).json({ error: 'You can only delete your own products' });
        }

        // Delete associated images from Cloudinary
        for (const img of product.images) {
            // Extract public_id from Cloudinary URL
            // URL format: https://res.cloudinary.com/.../arthings/item-uuid.ext
            try {
                const urlParts = img.imagePath.split('/');
                const fileWithExt = urlParts[urlParts.length - 1];
                const folder = urlParts[urlParts.length - 2];
                const publicId = folder + '/' + fileWithExt.split('.')[0];
                await cloudinary.uploader.destroy(publicId);
            } catch (imgErr) {
                console.error('Failed to delete image from Cloudinary:', imgErr.message);
            }
        }

        // Delete product (cascade will delete images, favorites, rentals)
        await prisma.item.delete({
            where: { id: numericId }
        });

        res.json({ message: 'Product deleted successfully' });

    } catch (error) {
        console.error('Delete product error:', error);
        res.status(500).json({ error: 'Failed to delete product' });
    }
});

module.exports = router;

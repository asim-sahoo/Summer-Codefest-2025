import express from 'express';
import multer from 'multer';
import path from 'path';
const router = express.Router();

// Storage configuration for multer
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, "public/images");
    },
    filename: (req, file, cb) => {
        // Generate a timestamp-based filename to avoid conflicts
        const timestamp = Date.now();
        // Extract extension from original filename
        const ext = path.extname(file.originalname);
        // Create a sanitized filename without spaces and special characters
        const sanitizedName = file.originalname
            .replace(ext, '') // Remove the extension first
            .replace(/[^a-zA-Z0-9]/g, '_') // Replace non-alphanumeric chars with underscore
            .substring(0, 50); // Limit the filename length

        // Final filename format: timestamp-sanitizedName.extension
        const filename = `${timestamp}-${sanitizedName}${ext}`;
        cb(null, filename);
    },
});

const upload = multer({
    storage: storage,
    fileFilter: (req, file, cb) => {
        // Accept only images
        const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/jpg'];
        if (allowedMimeTypes.includes(file.mimetype)) {
            cb(null, true);
        } else {
            cb(new Error('Invalid file type. Only JPEG, PNG, GIF, and WEBP images are allowed.'), false);
        }
    },
    limits: {
        fileSize: 10 * 1024 * 1024 // 10MB limit
    }
});

// Handle file upload
router.post('/', upload.single("file"), (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: "No file provided" });
        }
        
        // Return the URL for accessing the file
        return res.status(200).json({
            message: "File Uploaded Successfully",
            imageUrl: req.file.filename
        });
    } catch (error) {
        console.error("Upload error:", error);
        return res.status(500).json({ message: "Error uploading file", error: error.message });
    }
});

export default router;
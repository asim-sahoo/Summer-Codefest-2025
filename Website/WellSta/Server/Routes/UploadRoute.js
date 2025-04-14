import express from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';

const router = express.Router();

// Make sure public/images directory exists
const imagesDir = 'public/images';
if (!fs.existsSync(imagesDir)) {
    fs.mkdirSync(imagesDir, { recursive: true });
}

// Make sure public/audio directory exists
const audioDir = 'public/audio';
if (!fs.existsSync(audioDir)) {
    fs.mkdirSync(audioDir, { recursive: true });
}

// Configure storage for images
const imageStorage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, "public/images");
    },
    filename: (req, file, cb) => {
        cb(null, req.body.name);
    },
});

// Configure storage for voice notes
const audioStorage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, "public/audio");
    },
    filename: (req, file, cb) => {
        cb(null, req.body.name);
    },
});

// File filter to check file types
const fileFilter = (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
        req.fileType = 'image';
        cb(null, true);
    } else if (file.mimetype.startsWith('audio/')) {
        req.fileType = 'audio';
        cb(null, true);
    } else {
        cb(new Error('Unsupported file type'), false);
    }
};

// Custom storage function to route files to appropriate storage
const customStorage = multer.diskStorage({
    destination: (req, file, cb) => {
        if (file.mimetype.startsWith('image/')) {
            cb(null, "public/images");
        } else if (file.mimetype.startsWith('audio/')) {
            cb(null, "public/audio");
        } else {
            cb(new Error('Unsupported file type'), false);
        }
    },
    filename: (req, file, cb) => {
        cb(null, req.body.name);
    }
});

// Upload middleware with file type detection
const upload = multer({ 
    storage: customStorage,
    fileFilter
});

// Upload multiple files (images or audio notes)
router.post('/multiple', (req, res) => {
    console.log("Multiple files upload request received");
    
    const uploadMultiple = upload.array('files', 10);
    
    uploadMultiple(req, res, function(err) {
        if (err) {
            console.error("Error in multiple file upload:", err);
            return res.status(500).json({
                message: "Error uploading files",
                error: err.message
            });
        }
        
        if (!req.files || req.files.length === 0) {
            console.error("No files were uploaded");
            return res.status(400).json({
                message: "No files were uploaded"
            });
        }
        
        console.log(`Successfully uploaded ${req.files.length} files`);
        const fileNames = req.files.map(file => file.filename);
        
        return res.status(200).json({
            message: "Files uploaded successfully",
            fileNames: fileNames,
            fileType: req.fileType
        });
    });
});

// Upload a single file (image or audio note)
router.post('/', (req, res) => {
    console.log("Single file upload request received");
    
    const uploadSingle = upload.single("file");
    
    uploadSingle(req, res, function(err) {
        if (err) {
            console.error("Error in single file upload:", err);
            return res.status(500).json({
                message: "Error uploading file",
                error: err.message
            });
        }
        
        if (!req.file) {
            console.error("No file was uploaded");
            return res.status(400).json({
                message: "No file was uploaded"
            });
        }
        
        console.log(`Successfully uploaded file: ${req.file.filename}`);
        
        return res.status(200).json({
            message: "File uploaded successfully",
            fileName: req.file.filename,
            fileType: req.fileType
        });
    });
});

export default router;
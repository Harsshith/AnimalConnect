const multer = require('multer');
const path = require('path');
const fs = require('fs');
const env = require('./env');
const AppError = require('../utils/appError');

// Ensure local uploads directory exists
const uploadDir = path.resolve(__dirname, '../../', env.uploadPath);
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Local disk storage engine
const diskStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `${file.fieldname}-${uniqueSuffix}${ext}`);
  }
});

// File filter for images and documents
const fileFilter = (req, file, cb) => {
  const allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/jpg',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ];

  if (allowedMimeTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new AppError(`Unsupported file type: ${file.mimetype}. Allowed types: JPEG, PNG, WEBP, PDF, DOC.`, 400), false);
  }
};

const upload = multer({
  storage: diskStorage,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10 MB limit
  },
  fileFilter
});

// Cloudinary initialization (if configured)
let cloudinary = null;
if (
  env.storageType === 'cloudinary' &&
  env.cloudinary.cloudName &&
  env.cloudinary.apiKey &&
  env.cloudinary.apiSecret
) {
  cloudinary = require('cloudinary').v2;
  cloudinary.config({
    cloud_name: env.cloudinary.cloudName,
    api_key: env.cloudinary.apiKey,
    api_secret: env.cloudinary.apiSecret
  });
}

/**
 * Format file upload result into standard object
 */
const processUploadedFile = async (file, req) => {
  if (!file) return null;

  if (cloudinary && env.storageType === 'cloudinary') {
    try {
      const result = await cloudinary.uploader.upload(file.path, {
        folder: 'animal_connect'
      });
      // Optionally remove temp local file
      if (fs.existsSync(file.path)) {
        fs.unlinkSync(file.path);
      }
      return {
        url: result.secure_url,
        publicId: result.public_id,
        filename: file.originalname,
        mimetype: file.mimetype,
        size: file.size
      };
    } catch (err) {
      console.warn('[Cloudinary Upload Error, falling back to local]', err.message);
    }
  }

  // Local URL
  const baseUrl = `${req.protocol}://${req.get('host')}`;
  const fileUrl = `${baseUrl}/${env.uploadPath}/${file.filename}`;

  return {
    url: fileUrl,
    publicId: file.filename,
    filename: file.originalname,
    mimetype: file.mimetype,
    size: file.size
  };
};

module.exports = {
  upload,
  processUploadedFile,
  uploadDir
};

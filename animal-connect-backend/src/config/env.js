const dotenv = require('dotenv');
const path = require('path');

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

const env = {
  port: parseInt(process.env.PORT, 10) || 5000,
  nodeEnv: process.env.NODE_ENV || 'development',
  mongoUri: process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/animal_connect',
  clientUrl: process.env.CLIENT_URL || '*',
  jwtSecret: process.env.JWT_SECRET || 'animal_connect_jwt_secret_dev_2026',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  rateLimitWindowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS, 10) || 15 * 60 * 1000,
  rateLimitMax: parseInt(process.env.RATE_LIMIT_MAX, 10) || 500,
  storageType: process.env.STORAGE_TYPE || 'local',
  uploadPath: process.env.UPLOAD_PATH || 'uploads',
  cloudinary: {
    cloudName: process.env.CLOUDINARY_CLOUD_NAME || '',
    apiKey: process.env.CLOUDINARY_API_KEY || '',
    apiSecret: process.env.CLOUDINARY_API_SECRET || ''
  },
  initialAdmin: {
    name: process.env.INITIAL_ADMIN_NAME || 'Animal Connect Admin',
    email: process.env.INITIAL_ADMIN_EMAIL || 'admin@animalconnect.org',
    phone: process.env.INITIAL_ADMIN_PHONE || '+919876543210',
    password: process.env.INITIAL_ADMIN_PASSWORD || 'Admin@123456'
  }
};

module.exports = env;

const { upload, processUploadedFile } = require('../config/storage');
const AppError = require('../utils/appError');

/**
 * Handle single file upload with validation
 */
const uploadSingle = (fieldName) => {
  return (req, res, next) => {
    upload.single(fieldName)(req, res, (err) => {
      if (err) {
        if (err.code === 'LIMIT_FILE_SIZE') {
          return next(new AppError(`File too large. Maximum allowed size is 10MB.`, 400));
        }
        return next(err);
      }
      next();
    });
  };
};

/**
 * Handle multiple file uploads with validation
 */
const uploadMultiple = (fieldName, maxCount = 5) => {
  return (req, res, next) => {
    upload.array(fieldName, maxCount)(req, res, (err) => {
      if (err) {
        if (err.code === 'LIMIT_FILE_SIZE') {
          return next(new AppError(`File too large. Maximum allowed size is 10MB.`, 400));
        }
        if (err.code === 'LIMIT_UNEXPECTED_FILE') {
          return next(new AppError(`Too many files. Maximum allowed count is ${maxCount}.`, 400));
        }
        return next(err);
      }
      next();
    });
  };
};

module.exports = {
  uploadSingle,
  uploadMultiple,
  processUploadedFile
};

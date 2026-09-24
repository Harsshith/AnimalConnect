const ApiResponse = require('../utils/apiResponse');
const AppError = require('../utils/appError');
const env = require('../config/env');

const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;
  error.statusCode = err.statusCode || 500;

  // Log error in non-test environments
  if (env.nodeEnv !== 'test') {
    console.error(`[Error] ${req.method} ${req.originalUrl}:`, err);
  }

  // Mongoose Bad ObjectId (CastError)
  if (err.name === 'CastError') {
    const message = `Resource not found with id of ${err.value}`;
    error = new AppError(message, 404);
  }

  // Mongoose Duplicate Key Error (code 11000)
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue || {})[0] || 'field';
    const message = `Duplicate value entered for ${field}. Please use another value.`;
    error = new AppError(message, 400);
  }

  // Mongoose Validation Error
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors)
      .map((val) => val.message)
      .join(', ');
    error = new AppError(`Validation failed: ${message}`, 400);
  }

  // JWT Errors
  if (err.name === 'JsonWebTokenError') {
    error = new AppError('Invalid authentication token.', 401);
  }
  if (err.name === 'TokenExpiredError') {
    error = new AppError('Authentication token has expired. Please log in again.', 401);
  }

  // Express Multer error
  if (err.name === 'MulterError') {
    error = new AppError(`Upload error: ${err.message}`, 400);
  }

  const statusCode = error.statusCode || 500;
  const message = error.message || 'Internal server error';
  const errors = error.errors && error.errors.length > 0 ? error.errors : [message];

  return ApiResponse.error(res, message, errors, statusCode);
};

// 404 Not Found Middleware
const notFoundHandler = (req, res, next) => {
  next(new AppError(`Endpoint not found - ${req.originalUrl}`, 404));
};

module.exports = {
  errorHandler,
  notFoundHandler
};

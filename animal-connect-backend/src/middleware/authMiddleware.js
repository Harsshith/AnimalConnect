const jwt = require('jsonwebtoken');
const env = require('../config/env');
const User = require('../models/User');
const AppError = require('../utils/appError');
const asyncHandler = require('../utils/asyncHandler');

/**
 * Protect routes: Requires valid JWT Bearer token
 */
const protect = asyncHandler(async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return next(new AppError('Authentication token missing. Please log in.', 401));
  }

  try {
    const decoded = jwt.verify(token, env.jwtSecret);

    const currentUser = await User.findById(decoded.id).select('+password');
    if (!currentUser) {
      return next(new AppError('The user belonging to this token no longer exists.', 401));
    }

    if (!currentUser.isActive) {
      return next(new AppError('This account has been deactivated. Please contact support.', 403));
    }

    // Attach user to request object (without password)
    currentUser.password = undefined;
    req.user = currentUser;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return next(new AppError('Invalid authentication token.', 401));
    }
    if (error.name === 'TokenExpiredError') {
      return next(new AppError('Authentication token has expired. Please log in again.', 401));
    }
    return next(error);
  }
});

/**
 * Optional authentication: attaches user if valid token exists, otherwise proceeds as guest
 */
const optionalAuth = asyncHandler(async (req, res, next) => {
  let token;
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return next();
  }

  try {
    const decoded = jwt.verify(token, env.jwtSecret);
    const currentUser = await User.findById(decoded.id);
    if (currentUser && currentUser.isActive) {
      req.user = currentUser;
    }
  } catch (err) {
    // Ignore invalid token on optional auth
  }
  next();
});

module.exports = {
  protect,
  optionalAuth
};

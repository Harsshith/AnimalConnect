const jwt = require('jsonwebtoken');
const User = require('../models/User');
const VolunteerProfile = require('../models/VolunteerProfile');
const ApiResponse = require('../utils/apiResponse');
const AppError = require('../utils/appError');
const asyncHandler = require('../utils/asyncHandler');
const env = require('../config/env');

// Helper to sign JWT token
const signToken = (id) => {
  return jwt.sign({ id }, env.jwtSecret, {
    expiresIn: env.jwtExpiresIn
  });
};

/**
 * @desc    Register a new user
 * @route   POST /api/auth/register
 * @access  Public
 */
const register = asyncHandler(async (req, res) => {
  const { fullName, email, phone, password, role, address, city } = req.body;

  // Check if user already exists
  const existingEmail = await User.findOne({ email });
  if (existingEmail) {
    throw new AppError('An account with this email address already exists.', 400);
  }

  const existingPhone = await User.findOne({ phone });
  if (existingPhone) {
    throw new AppError('An account with this phone number already exists.', 400);
  }

  // Facility roles start as unverified until admin checks
  const isFacilityRole = ['hospital', 'clinic', 'shelter', 'pet_care_provider', 'medicine_provider'].includes(role);
  const isVerified = !isFacilityRole; // Public users / volunteers start verified

  // Create user
  const user = await User.create({
    fullName,
    email,
    phone,
    password,
    role: role || 'volunteer',
    address: address || '',
    city: city || '',
    isVerified
  });

  // If user registered as volunteer or public user, automatically create a default VolunteerProfile
  if (user.role === 'volunteer' || user.role === 'public_user') {
    await VolunteerProfile.create({
      userId: user._id,
      capabilities: [
        'Transport animals',
        'Provide temporary care',
        'Help with medicine pickup',
        'Support adoption',
        'Donate'
      ],
      isAvailable: true,
      serviceArea: city || '',
      city: city || ''
    });
  }

  const token = signToken(user._id);

  return ApiResponse.success(
    res,
    'User registered successfully.',
    {
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        phone: user.phone,
        role: user.role,
        isVerified: user.isVerified,
        address: user.address,
        city: user.city
      },
      token
    },
    201
  );
});

/**
 * @desc    Login user
 * @route   POST /api/auth/login
 * @access  Public
 */
const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  // Find user with password field explicitly selected
  const user = await User.findOne({ email }).select('+password');
  if (!user) {
    throw new AppError('Invalid email or password.', 401);
  }

  if (!user.isActive) {
    throw new AppError('Your account has been deactivated. Please contact support.', 403);
  }

  const isMatch = await user.comparePassword(password);
  if (!isMatch) {
    throw new AppError('Invalid email or password.', 401);
  }

  const token = signToken(user._id);

  return ApiResponse.success(res, 'Logged in successfully.', {
    user: {
      id: user._id,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      role: user.role,
      isVerified: user.isVerified,
      profileImage: user.profileImage,
      address: user.address,
      city: user.city
    },
    token
  });
});

/**
 * @desc    Get current logged in user profile
 * @route   GET /api/auth/me
 * @access  Private
 */
const getMe = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  return ApiResponse.success(res, 'Profile retrieved successfully.', { user });
});

/**
 * @desc    Update user profile
 * @route   PUT /api/auth/profile
 * @access  Private
 */
const updateProfile = asyncHandler(async (req, res) => {
  const { fullName, phone, address, city, profileImage } = req.body;

  const user = await User.findById(req.user._id);
  if (!user) {
    throw new AppError('User not found.', 404);
  }

  if (phone && phone !== user.phone) {
    const phoneExists = await User.findOne({ phone, _id: { $ne: user._id } });
    if (phoneExists) {
      throw new AppError('This phone number is already registered by another account.', 400);
    }
    user.phone = phone;
  }

  if (fullName) user.fullName = fullName;
  if (address !== undefined) user.address = address;
  if (city !== undefined) user.city = city;
  if (profileImage !== undefined) user.profileImage = profileImage;

  await user.save();

  return ApiResponse.success(res, 'Profile updated successfully.', { user });
});

/**
 * @desc    Change password
 * @route   PUT /api/auth/change-password
 * @access  Private
 */
const changePassword = asyncHandler(async (req, res) => {
  const { currentPassword, newPassword } = req.body;

  const user = await User.findById(req.user._id).select('+password');
  const isMatch = await user.comparePassword(currentPassword);
  if (!isMatch) {
    throw new AppError('Current password is incorrect.', 400);
  }

  user.password = newPassword;
  await user.save();

  return ApiResponse.success(res, 'Password changed successfully.');
});

/**
 * @desc    Logout user
 * @route   POST /api/auth/logout
 * @access  Private
 */
const logout = asyncHandler(async (req, res) => {
  // Stateless JWT logout - frontend clears the token
  return ApiResponse.success(res, 'Logged out successfully.');
});

module.exports = {
  register,
  login,
  getMe,
  updateProfile,
  changePassword,
  logout
};

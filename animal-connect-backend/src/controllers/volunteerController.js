const VolunteerProfile = require('../models/VolunteerProfile');
const ApiResponse = require('../utils/apiResponse');
const AppError = require('../utils/appError');
const asyncHandler = require('../utils/asyncHandler');

/**
 * @desc    Create or update volunteer profile
 * @route   POST /api/volunteers/profile
 * @access  Private
 */
const createOrUpdateProfile = asyncHandler(async (req, res) => {
  const { capabilities, isAvailable, serviceArea, city } = req.body;

  let profile = await VolunteerProfile.findOne({ userId: req.user._id });

  if (profile) {
    if (capabilities) profile.capabilities = capabilities;
    if (isAvailable !== undefined) profile.isAvailable = isAvailable;
    if (serviceArea !== undefined) profile.serviceArea = serviceArea;
    if (city !== undefined) profile.city = city;
    await profile.save();
  } else {
    profile = await VolunteerProfile.create({
      userId: req.user._id,
      capabilities: capabilities || [],
      isAvailable: isAvailable !== undefined ? isAvailable : true,
      serviceArea: serviceArea || '',
      city: city || req.user.city || ''
    });
  }

  return ApiResponse.success(res, 'Volunteer profile saved successfully.', { profile });
});

/**
 * @desc    Get current user's volunteer profile
 * @route   GET /api/volunteers/profile
 * @access  Private
 */
const getMyProfile = asyncHandler(async (req, res) => {
  let profile = await VolunteerProfile.findOne({ userId: req.user._id }).populate(
    'userId',
    'fullName email phone city profileImage'
  );

  if (!profile) {
    // Create default profile if not exists
    profile = await VolunteerProfile.create({
      userId: req.user._id,
      capabilities: [
        'Transport animals',
        'Provide temporary care',
        'Help with medicine pickup',
        'Support adoption',
        'Donate'
      ],
      isAvailable: true,
      serviceArea: req.user.city || '',
      city: req.user.city || ''
    });
    profile = await profile.populate('userId', 'fullName email phone city profileImage');
  }

  return ApiResponse.success(res, 'Volunteer profile retrieved successfully.', { profile });
});

/**
 * @desc    Update volunteer profile
 * @route   PUT /api/volunteers/profile
 * @access  Private
 */
const updateProfile = asyncHandler(async (req, res) => {
  const { capabilities, serviceArea, city } = req.body;

  let profile = await VolunteerProfile.findOne({ userId: req.user._id });
  if (!profile) {
    throw new AppError('Volunteer profile not found.', 404);
  }

  if (capabilities) profile.capabilities = capabilities;
  if (serviceArea !== undefined) profile.serviceArea = serviceArea;
  if (city !== undefined) profile.city = city;

  await profile.save();

  return ApiResponse.success(res, 'Volunteer profile updated successfully.', { profile });
});

/**
 * @desc    Update volunteer availability
 * @route   PUT /api/volunteers/availability
 * @access  Private
 */
const updateAvailability = asyncHandler(async (req, res) => {
  const { isAvailable } = req.body;

  if (isAvailable === undefined) {
    throw new AppError('isAvailable flag is required.', 400);
  }

  let profile = await VolunteerProfile.findOne({ userId: req.user._id });
  if (!profile) {
    profile = await VolunteerProfile.create({
      userId: req.user._id,
      isAvailable: Boolean(isAvailable)
    });
  } else {
    profile.isAvailable = Boolean(isAvailable);
    await profile.save();
  }

  return ApiResponse.success(res, 'Volunteer availability updated.', {
    isAvailable: profile.isAvailable
  });
});

module.exports = {
  createOrUpdateProfile,
  getMyProfile,
  updateProfile,
  updateAvailability
};

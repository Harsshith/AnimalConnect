const PetCareProvider = require('../models/PetCareProvider');
const ApiResponse = require('../utils/apiResponse');
const AppError = require('../utils/appError');
const asyncHandler = require('../utils/asyncHandler');
const { generateId } = require('../utils/idGenerator');
const NotificationService = require('../services/notificationService');

/**
 * @desc    Register as a pet care provider
 * @route   POST /api/pet-care/register
 * @access  Private
 */
const registerProvider = asyncHandler(async (req, res) => {
  const {
    name,
    serviceType,
    pricePerDay,
    location,
    phone,
    description,
    imageUrl,
    longitude,
    latitude
  } = req.body;

  const coordinates = [
    parseFloat(longitude) || 76.9558,
    parseFloat(latitude) || 11.0168
  ];

  const provider = await PetCareProvider.create({
    user: req.user._id,
    name,
    serviceType,
    pricePerDay: parseFloat(pricePerDay) || 400,
    location,
    coordinates,
    phone: phone || req.user.phone,
    description: description || '',
    imageUrl: imageUrl || 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=600',
    isVerified: false,
    verificationStatus: 'pending',
    availabilityStatus: 'Available'
  });

  return ApiResponse.success(
    res,
    'Pet care provider registered. Pending administrative verification.',
    { provider },
    201
  );
});

/**
 * @desc    Get all pet care providers
 * @route   GET /api/pet-care
 * @access  Public
 */
const getProviders = asyncHandler(async (req, res) => {
  const { serviceType, availabilityStatus, isVerified, location } = req.query;

  const query = {};
  if (serviceType) query.serviceType = serviceType;
  if (availabilityStatus) query.availabilityStatus = availabilityStatus;
  if (isVerified !== undefined) query.isVerified = isVerified === 'true';
  if (location) query.location = new RegExp(location, 'i');

  const providers = await PetCareProvider.find(query).sort('-rating');
  return ApiResponse.success(res, 'Pet care providers retrieved.', { providers });
});

/**
 * @desc    Get provider by ID
 * @route   GET /api/pet-care/:id
 * @access  Public
 */
const getProviderById = asyncHandler(async (req, res) => {
  const provider = await PetCareProvider.findById(req.params.id);
  if (!provider) {
    throw new AppError('Pet care provider not found.', 404);
  }

  return ApiResponse.success(res, 'Provider details retrieved.', { provider });
});

/**
 * @desc    Update pet care provider profile
 * @route   PUT /api/pet-care/:id
 * @access  Private (Owner or Admin)
 */
const updateProvider = asyncHandler(async (req, res) => {
  const provider = await PetCareProvider.findById(req.params.id);
  if (!provider) {
    throw new AppError('Provider not found.', 404);
  }

  const isOwner = String(provider.user) === String(req.user._id);
  const isAdmin = req.user.role === 'admin';
  if (!isOwner && !isAdmin) {
    throw new AppError('Not authorized to update this provider profile.', 403);
  }

  const {
    name,
    serviceType,
    pricePerDay,
    location,
    phone,
    description,
    availabilityStatus,
    imageUrl,
    verificationStatus
  } = req.body;

  // Security: Cannot approve own verification
  if (verificationStatus && !isAdmin) {
    throw new AppError('Cannot modify verification status.', 403);
  }

  if (name) provider.name = name;
  if (serviceType) provider.serviceType = serviceType;
  if (pricePerDay !== undefined) provider.pricePerDay = parseFloat(pricePerDay);
  if (location) provider.location = location;
  if (phone) provider.phone = phone;
  if (description !== undefined) provider.description = description;
  if (availabilityStatus) provider.availabilityStatus = availabilityStatus;
  if (imageUrl) provider.imageUrl = imageUrl;

  await provider.save();
  return ApiResponse.success(res, 'Pet care provider profile updated.', { provider });
});

/**
 * @desc    Book a pet care provider
 * @route   POST /api/pet-care/:id/book
 * @access  Private
 */
const bookProvider = asyncHandler(async (req, res) => {
  const provider = await PetCareProvider.findById(req.params.id);
  if (!provider) {
    throw new AppError('Provider not found.', 404);
  }

  if (provider.availabilityStatus === 'Fully Booked') {
    throw new AppError('Provider is currently fully booked.', 400);
  }

  const { animalType, service, startDate, endDate, totalAmount } = req.body;
  const bookingId = generateId('BOOK');

  const newBooking = {
    bookingId,
    user: req.user._id,
    animalType: animalType || 'Dog',
    service: service || provider.serviceType,
    startDate: new Date(startDate || Date.now()),
    endDate: new Date(endDate || Date.now() + 24 * 60 * 60 * 1000),
    totalAmount: parseFloat(totalAmount) || provider.pricePerDay,
    status: 'pending'
  };

  provider.bookings.push(newBooking);
  await provider.save();

  // Notify provider user
  await NotificationService.send({
    userId: provider.user,
    title: `New Pet Care Booking (${bookingId})`,
    body: `${req.user.fullName} requested ${newBooking.service} booking.`,
    category: 'General'
  });

  return ApiResponse.success(res, 'Booking request submitted successfully.', {
    booking: newBooking
  }, 201);
});

module.exports = {
  registerProvider,
  getProviders,
  getProviderById,
  updateProvider,
  bookProvider
};

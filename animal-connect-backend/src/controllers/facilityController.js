const Facility = require('../models/Facility');
const AnimalCase = require('../models/AnimalCase');
const CaseStatusHistory = require('../models/CaseStatusHistory');
const ApiResponse = require('../utils/apiResponse');
const AppError = require('../utils/appError');
const asyncHandler = require('../utils/asyncHandler');
const { processUploadedFile } = require('../config/storage');
const NotificationService = require('../services/notificationService');

/**
 * @desc    Register a hospital
 * @route   POST /api/facilities/hospitals/register
 * @access  Private
 */
const registerHospital = asyncHandler(async (req, res) => {
  return registerFacilityWithType(req, res, 'hospital');
});

/**
 * @desc    Register a veterinary clinic
 * @route   POST /api/facilities/clinics/register
 * @access  Private
 */
const registerClinic = asyncHandler(async (req, res) => {
  return registerFacilityWithType(req, res, 'clinic');
});

/**
 * Helper to register a facility
 */
const registerFacilityWithType = async (req, res, defaultType) => {
  const {
    name,
    type = defaultType,
    phone,
    email,
    address,
    city,
    longitude,
    latitude,
    openHours,
    hasEmergency,
    offersSupportedCare,
    services
  } = req.body;

  // Process registration document if uploaded
  let registrationDocuments = [];
  if (req.file) {
    const doc = await processUploadedFile(req.file, req);
    if (doc) {
      registrationDocuments.push({
        title: 'Facility Registration License',
        url: doc.url
      });
    }
  }

  const coordinates = [
    parseFloat(longitude) || 76.9558,
    parseFloat(latitude) || 11.0168
  ];

  // Facility always starts as unverified pending admin approval
  const facility = await Facility.create({
    name,
    type,
    owner: req.user._id,
    phone,
    email: email || req.user.email,
    address,
    city,
    location: {
      type: 'Point',
      coordinates
    },
    isVerified: false,
    verificationStatus: 'pending',
    openHours: openHours || '24 Hours Emergency',
    isOpenNow: true,
    hasEmergency: hasEmergency !== undefined ? Boolean(hasEmergency) : true,
    offersSupportedCare: offersSupportedCare !== undefined ? Boolean(offersSupportedCare) : true,
    services: Array.isArray(services) ? services : (services ? services.split(',') : ['Emergency', 'Surgery', 'Vaccination']),
    registrationDocuments
  });

  return ApiResponse.success(
    res,
    'Facility registered successfully. Account is pending verification by an administrator.',
    { facility },
    201
  );
};

/**
 * @desc    Get facilities with filtering and pagination
 * @route   GET /api/facilities
 * @access  Public
 */
const getFacilities = asyncHandler(async (req, res) => {
  const { type, isVerified, city, search, page = 1, limit = 20 } = req.query;

  const query = {};
  if (type) query.type = type;
  if (isVerified !== undefined) query.isVerified = isVerified === 'true';
  if (city) query.city = new RegExp(city, 'i');
  if (search) {
    query.$or = [
      { name: new RegExp(search, 'i') },
      { address: new RegExp(search, 'i') },
      { city: new RegExp(search, 'i') }
    ];
  }

  const pageNum = parseInt(page, 10) || 1;
  const limitNum = parseInt(limit, 10) || 20;
  const skip = (pageNum - 1) * limitNum;

  const total = await Facility.countDocuments(query);
  const facilities = await Facility.find(query)
    .populate('owner', 'fullName email phone')
    .sort('-rating')
    .skip(skip)
    .limit(limitNum);

  return ApiResponse.paginated(res, 'Facilities retrieved.', facilities, {
    total,
    page: pageNum,
    limit: limitNum,
    totalPages: Math.ceil(total / limitNum)
  });
});

/**
 * @desc    Get nearby facilities using geospatial coordinates
 * @route   GET /api/facilities/nearby
 * @access  Public
 */
const getNearbyFacilities = asyncHandler(async (req, res) => {
  const { latitude, longitude, radius = 25, type } = req.query;

  if (!latitude || !longitude) {
    throw new AppError('Latitude and longitude are required query parameters.', 400);
  }

  const lat = parseFloat(latitude);
  const lng = parseFloat(longitude);
  const radiusKm = parseFloat(radius);
  const radiusMeters = radiusKm * 1000;

  const matchStage = {};
  if (type) matchStage.type = type;

  // MongoDB $geoNear aggregation
  const facilities = await Facility.aggregate([
    {
      $geoNear: {
        near: {
          type: 'Point',
          coordinates: [lng, lat]
        },
        distanceField: 'distanceMeters',
        maxDistance: radiusMeters,
        spherical: true,
        query: matchStage
      }
    },
    {
      $addFields: {
        distanceKm: {
          $round: [{ $divide: ['$distanceMeters', 1000] }, 1]
        }
      }
    },
    {
      $sort: { distanceMeters: 1 }
    }
  ]);

  return ApiResponse.success(res, 'Nearby facilities retrieved.', {
    count: facilities.length,
    radiusKm,
    facilities
  });
});

/**
 * @desc    Get facility by ID
 * @route   GET /api/facilities/:id
 * @access  Public
 */
const getFacilityById = asyncHandler(async (req, res) => {
  const facility = await Facility.findById(req.params.id).populate('owner', 'fullName email phone');
  if (!facility) {
    throw new AppError('Facility not found.', 404);
  }

  return ApiResponse.success(res, 'Facility details retrieved.', { facility });
});

/**
 * @desc    Update facility profile
 * @route   PUT /api/facilities/:id
 * @access  Private (Owner or Admin)
 */
const updateFacility = asyncHandler(async (req, res) => {
  const facility = await Facility.findById(req.params.id);
  if (!facility) {
    throw new AppError('Facility not found.', 404);
  }

  const isOwner = String(facility.owner) === String(req.user._id);
  const isAdmin = req.user.role === 'admin';

  if (!isOwner && !isAdmin) {
    throw new AppError('Not authorized to update this facility.', 403);
  }

  const {
    name,
    phone,
    email,
    address,
    city,
    openHours,
    isOpenNow,
    hasEmergency,
    offersSupportedCare,
    services,
    capacity,
    currentOccupancy,
    verificationStatus // IMPORTANT: check authorization!
  } = req.body;

  // SECURITY CHECK: Facility MUST NOT approve its own verification!
  if (verificationStatus && !isAdmin) {
    throw new AppError('Facilities cannot approve or modify their own verification status.', 403);
  }

  if (name) facility.name = name;
  if (phone) facility.phone = phone;
  if (email) facility.email = email;
  if (address) facility.address = address;
  if (city) facility.city = city;
  if (openHours) facility.openHours = openHours;
  if (isOpenNow !== undefined) facility.isOpenNow = Boolean(isOpenNow);
  if (hasEmergency !== undefined) facility.hasEmergency = Boolean(hasEmergency);
  if (offersSupportedCare !== undefined) facility.offersSupportedCare = Boolean(offersSupportedCare);
  if (services) facility.services = Array.isArray(services) ? services : services.split(',');
  if (capacity !== undefined) facility.capacity = parseInt(capacity, 10);
  if (currentOccupancy !== undefined) facility.currentOccupancy = parseInt(currentOccupancy, 10);

  if (req.file) {
    const photo = await processUploadedFile(req.file, req);
    if (photo) facility.imageUrl = photo.url;
  }

  await facility.save();

  return ApiResponse.success(res, 'Facility profile updated successfully.', { facility });
});

/**
 * @desc    Get cases assigned to a facility
 * @route   GET /api/facilities/:id/cases
 * @access  Private
 */
const getFacilityCases = asyncHandler(async (req, res) => {
  const facility = await Facility.findById(req.params.id);
  if (!facility) {
    throw new AppError('Facility not found.', 404);
  }

  const cases = await AnimalCase.find({ selectedFacility: facility._id })
    .populate('reporter', 'fullName phone')
    .sort('-createdAt');

  return ApiResponse.success(res, 'Assigned cases retrieved.', { cases });
});

/**
 * @desc    Accept a case at the facility
 * @route   POST /api/facilities/:id/cases/:caseId/accept
 * @access  Private (Facility or Admin)
 */
const acceptCase = asyncHandler(async (req, res) => {
  const { id: facilityId, caseId } = req.params;
  const animalCase = await AnimalCase.findById(caseId);
  if (!animalCase) {
    throw new AppError('Case not found.', 404);
  }

  const facility = await Facility.findById(facilityId);
  if (!facility) {
    throw new AppError('Facility not found.', 404);
  }

  const oldStatus = animalCase.status;
  animalCase.selectedFacility = facility._id;
  animalCase.selectedFacilityName = facility.name;
  animalCase.status = 'Admitted';
  await animalCase.save();

  // Audit status transition
  await CaseStatusHistory.create({
    caseId: animalCase._id,
    previousStatus: oldStatus,
    newStatus: 'Admitted',
    changedBy: req.user._id,
    changerRole: req.user.role,
    remarks: `Admitted by ${facility.name}`
  });

  // Notify reporter
  await NotificationService.send({
    userId: animalCase.reporter,
    title: `Animal Admitted at ${facility.name}`,
    body: `Your case (${animalCase.caseId}) has been accepted and admitted for care.`,
    category: 'Case',
    caseId: animalCase._id
  });

  return ApiResponse.success(res, 'Case accepted and admitted.', { case: animalCase });
});

module.exports = {
  registerHospital,
  registerClinic,
  getFacilities,
  getNearbyFacilities,
  getFacilityById,
  updateFacility,
  getFacilityCases,
  acceptCase
};

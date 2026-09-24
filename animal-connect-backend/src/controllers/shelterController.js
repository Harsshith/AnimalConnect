const Facility = require('../models/Facility');
const ShelterAdmission = require('../models/ShelterAdmission');
const AnimalCase = require('../models/AnimalCase');
const ApiResponse = require('../utils/apiResponse');
const AppError = require('../utils/appError');
const asyncHandler = require('../utils/asyncHandler');
const NotificationService = require('../services/notificationService');

/**
 * @desc    Register a shelter
 * @route   POST /api/shelters/register
 * @access  Private
 */
const registerShelter = asyncHandler(async (req, res) => {
  const {
    name,
    phone,
    email,
    address,
    city,
    longitude,
    latitude,
    capacity,
    openHours,
    services
  } = req.body;

  const coordinates = [
    parseFloat(longitude) || 76.9558,
    parseFloat(latitude) || 11.0168
  ];

  const shelter = await Facility.create({
    name,
    type: 'shelter',
    owner: req.user._id,
    phone,
    email: email || req.user.email,
    address,
    city,
    location: {
      type: 'Point',
      coordinates
    },
    capacity: parseInt(capacity, 10) || 50,
    currentOccupancy: 0,
    isVerified: false,
    verificationStatus: 'pending',
    openHours: openHours || '9:00 AM - 6:00 PM',
    services: Array.isArray(services) ? services : ['Shelter Care', 'Rehabilitation', 'Adoption Assistance']
  });

  return ApiResponse.success(
    res,
    'Shelter registered successfully. Awaiting administrator verification.',
    { shelter },
    201
  );
});

/**
 * @desc    Get all shelters
 * @route   GET /api/shelters
 * @access  Public
 */
const getShelters = asyncHandler(async (req, res) => {
  const { city, isVerified } = req.query;
  const query = { type: 'shelter' };
  if (city) query.city = new RegExp(city, 'i');
  if (isVerified !== undefined) query.isVerified = isVerified === 'true';

  const shelters = await Facility.find(query).sort('-createdAt');
  return ApiResponse.success(res, 'Shelters retrieved.', { shelters });
});

/**
 * @desc    Get shelter by ID
 * @route   GET /api/shelters/:id
 * @access  Public
 */
const getShelterById = asyncHandler(async (req, res) => {
  const shelter = await Facility.findOne({ _id: req.params.id, type: 'shelter' });
  if (!shelter) {
    throw new AppError('Shelter not found.', 404);
  }

  return ApiResponse.success(res, 'Shelter details retrieved.', { shelter });
});

/**
 * @desc    Update shelter details
 * @route   PUT /api/shelters/:id
 * @access  Private (Shelter Owner or Admin)
 */
const updateShelter = asyncHandler(async (req, res) => {
  const shelter = await Facility.findOne({ _id: req.params.id, type: 'shelter' });
  if (!shelter) {
    throw new AppError('Shelter not found.', 404);
  }

  const isOwner = String(shelter.owner) === String(req.user._id);
  const isAdmin = req.user.role === 'admin';
  if (!isOwner && !isAdmin) {
    throw new AppError('Not authorized to update this shelter.', 403);
  }

  const { capacity, currentOccupancy, phone, address, city, openHours } = req.body;
  if (capacity !== undefined) shelter.capacity = parseInt(capacity, 10);
  if (currentOccupancy !== undefined) {
    const newOccupancy = parseInt(currentOccupancy, 10);
    if (newOccupancy > shelter.capacity) {
      throw new AppError(`Occupancy cannot exceed capacity (${shelter.capacity}).`, 400);
    }
    shelter.currentOccupancy = newOccupancy;
  }
  if (phone) shelter.phone = phone;
  if (address) shelter.address = address;
  if (city) shelter.city = city;
  if (openHours) shelter.openHours = openHours;

  await shelter.save();
  return ApiResponse.success(res, 'Shelter updated successfully.', { shelter });
});

/**
 * @desc    Submit an animal admission request to shelter
 * @route   POST /api/shelters/:id/admission-requests
 * @access  Private
 */
const requestAdmission = asyncHandler(async (req, res) => {
  const shelter = await Facility.findOne({ _id: req.params.id, type: 'shelter' });
  if (!shelter) {
    throw new AppError('Shelter not found.', 404);
  }

  // Check capacity limit
  if (shelter.currentOccupancy >= shelter.capacity) {
    throw new AppError('Shelter is currently at maximum capacity. Cannot admit new animals.', 400);
  }

  const { caseId, animalName, remarks } = req.body;

  const admission = await ShelterAdmission.create({
    shelterId: shelter._id,
    caseId,
    requestedBy: req.user._id,
    animalName: animalName || 'Rescue Animal',
    remarks: remarks || '',
    status: 'pending'
  });

  return ApiResponse.success(
    res,
    'Admission request submitted successfully.',
    { admission },
    201
  );
});

/**
 * @desc    Update admission request (Accept/Reject/Discharge)
 * @route   PUT /api/admission-requests/:id
 * @access  Private (Shelter Owner or Admin)
 */
const updateAdmissionRequest = asyncHandler(async (req, res) => {
  const admission = await ShelterAdmission.findById(req.params.id);
  if (!admission) {
    throw new AppError('Admission request not found.', 404);
  }

  const shelter = await Facility.findById(admission.shelterId);
  if (!shelter) {
    throw new AppError('Associated shelter not found.', 404);
  }

  const isOwner = String(shelter.owner) === String(req.user._id);
  const isAdmin = req.user.role === 'admin';
  if (!isOwner && !isAdmin) {
    throw new AppError('Not authorized to respond to this admission request.', 403);
  }

  const { status, assignedKennelOrArea, remarks, careNote } = req.body;

  if (status === 'approved' && admission.status !== 'approved') {
    // Prevent capacity overflow
    if (shelter.currentOccupancy >= shelter.capacity) {
      throw new AppError(`Cannot approve: shelter is at full capacity (${shelter.capacity}).`, 400);
    }
    shelter.currentOccupancy += 1;
    await shelter.save();

    admission.status = 'approved';
    admission.admissionDate = new Date();

    // Update animal case if linked
    if (admission.caseId) {
      const animalCase = await AnimalCase.findById(admission.caseId);
      if (animalCase) {
        animalCase.status = 'Shelter Care';
        animalCase.selectedFacility = shelter._id;
        animalCase.selectedFacilityName = shelter.name;
        await animalCase.save();
      }
    }
  } else if (status === 'discharged' && admission.status === 'approved') {
    shelter.currentOccupancy = Math.max(0, shelter.currentOccupancy - 1);
    await shelter.save();
    admission.status = 'discharged';
    admission.dischargeDate = new Date();
  } else if (status === 'rejected') {
    admission.status = 'rejected';
  }

  if (assignedKennelOrArea) admission.assignedKennelOrArea = assignedKennelOrArea;
  if (remarks) admission.remarks = remarks;

  if (careNote) {
    admission.careNotes.push({
      note: careNote,
      author: req.user._id,
      timestamp: new Date()
    });
  }

  await admission.save();

  // Notify applicant
  await NotificationService.send({
    userId: admission.requestedBy,
    title: `Shelter Admission Update`,
    body: `Your admission request for ${admission.animalName} is now ${admission.status}.`,
    category: 'Case',
    caseId: admission.caseId
  });

  return ApiResponse.success(res, 'Admission request updated.', {
    admission,
    shelterOccupancy: shelter.currentOccupancy,
    shelterCapacity: shelter.capacity
  });
});

module.exports = {
  registerShelter,
  getShelters,
  getShelterById,
  updateShelter,
  requestAdmission,
  updateAdmissionRequest
};

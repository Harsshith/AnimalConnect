const AnimalCase = require('../models/AnimalCase');
const CaseStatusHistory = require('../models/CaseStatusHistory');
const Facility = require('../models/Facility');
const ApiResponse = require('../utils/apiResponse');
const AppError = require('../utils/appError');
const asyncHandler = require('../utils/asyncHandler');
const { generateCaseId } = require('../utils/idGenerator');
const { processUploadedFile } = require('../config/storage');
const NotificationService = require('../services/notificationService');

/**
 * @desc    Create a new animal case
 * @route   POST /api/cases
 * @access  Private
 */
const createCase = asyncHandler(async (req, res) => {
  const {
    animalType,
    condition,
    description,
    ageGroup,
    gender,
    locationAddress,
    landmark,
    volunteerAction,
    selectedFacilityId,
    priority,
    longitude,
    latitude,
    imageUrl
  } = req.body;

  const caseId = generateCaseId();

  // Process uploaded images if provided
  let images = [];
  if (req.files && req.files.length > 0) {
    for (const file of req.files) {
      const processed = await processUploadedFile(file, req);
      if (processed) {
        images.push({
          url: processed.url,
          publicId: processed.publicId,
          uploadedBy: req.user._id,
          uploadedRole: req.user.role
        });
      }
    }
  } else if (req.file) {
    const processed = await processUploadedFile(req.file, req);
    if (processed) {
      images.push({
        url: processed.url,
        publicId: processed.publicId,
        uploadedBy: req.user._id,
        uploadedRole: req.user.role
      });
    }
  } else if (imageUrl) {
    // If image URL passed directly in body (e.g. Flutter mock or third-party)
    images.push({
      url: imageUrl,
      uploadedBy: req.user._id,
      uploadedRole: req.user.role
    });
  }

  // Facility name resolution
  let facilityName = '';
  if (selectedFacilityId) {
    const fac = await Facility.findById(selectedFacilityId);
    if (fac) facilityName = fac.name;
  }

  // Coordinates
  const coordinates = [
    parseFloat(longitude) || 76.9558,
    parseFloat(latitude) || 11.0168
  ];

  const initialStatus = selectedFacilityId ? 'Facility Selected' : 'Reported';

  const newCase = await AnimalCase.create({
    caseId,
    reporter: req.user._id,
    reporterName: req.user.fullName,
    reporterPhone: req.user.phone,
    animalType,
    condition,
    description,
    ageGroup: ageGroup || 'Unknown',
    gender: gender || 'Unknown',
    locationAddress,
    landmark: landmark || '',
    location: {
      type: 'Point',
      coordinates
    },
    images,
    volunteerAction: volunteerAction || 'Need Help',
    selectedFacility: selectedFacilityId || null,
    selectedFacilityName: facilityName,
    status: initialStatus,
    priority: priority || (condition === 'Critical' ? 'Critical' : 'Medium')
  });

  // Record status history
  await CaseStatusHistory.create({
    caseId: newCase._id,
    previousStatus: 'None',
    newStatus: initialStatus,
    changedBy: req.user._id,
    changerRole: req.user.role,
    remarks: 'Case reported by user'
  });

  // Dispatch notification to user
  await NotificationService.send({
    userId: req.user._id,
    title: `Case Reported (${caseId})`,
    body: `Your case for a ${condition.toLowerCase()} ${animalType.toLowerCase()} has been successfully logged.`,
    category: 'Case',
    caseId: newCase._id
  });

  return ApiResponse.success(res, 'Animal case reported successfully.', { case: newCase }, 201);
});

/**
 * @desc    Get all cases with filtering and pagination
 * @route   GET /api/cases
 * @access  Public / Authenticated
 */
const getCases = asyncHandler(async (req, res) => {
  const {
    status,
    condition,
    priority,
    animalType,
    search,
    facilityId,
    page = 1,
    limit = 20,
    sort = '-createdAt'
  } = req.query;

  const query = {};

  if (status) query.status = status;
  if (condition) query.condition = condition;
  if (priority) query.priority = priority;
  if (animalType) query.animalType = new RegExp(animalType, 'i');
  if (facilityId) query.selectedFacility = facilityId;

  if (search) {
    query.$or = [
      { caseId: new RegExp(search, 'i') },
      { description: new RegExp(search, 'i') },
      { locationAddress: new RegExp(search, 'i') },
      { animalType: new RegExp(search, 'i') }
    ];
  }

  const pageNum = parseInt(page, 10) || 1;
  const limitNum = parseInt(limit, 10) || 20;
  const skip = (pageNum - 1) * limitNum;

  const total = await AnimalCase.countDocuments(query);
  const cases = await AnimalCase.find(query)
    .populate('selectedFacility', 'name phone address city type isVerified')
    .sort(sort)
    .skip(skip)
    .limit(limitNum);

  return ApiResponse.paginated(
    res,
    'Cases retrieved successfully.',
    cases,
    {
      total,
      page: pageNum,
      limit: limitNum,
      totalPages: Math.ceil(total / limitNum)
    }
  );
});

/**
 * @desc    Get case details by ID
 * @route   GET /api/cases/:id
 * @access  Public / Authenticated
 */
const getCaseById = asyncHandler(async (req, res) => {
  const animalCase = await AnimalCase.findById(req.params.id)
    .populate('reporter', 'fullName phone email')
    .populate('selectedFacility', 'name type phone address city isVerified');

  if (!animalCase) {
    throw new AppError('Case not found.', 404);
  }

  const history = await CaseStatusHistory.find({ caseId: animalCase._id })
    .populate('changedBy', 'fullName role')
    .sort('-createdAt');

  return ApiResponse.success(res, 'Case details retrieved.', {
    case: animalCase,
    history
  });
});

/**
 * @desc    Update animal case status & details
 * @route   PUT /api/cases/:id
 * @access  Private
 */
const updateCase = asyncHandler(async (req, res) => {
  const {
    status,
    selectedFacilityId,
    volunteerAction,
    priority,
    estimatedCost,
    pawcareSupport,
    donorSupport,
    remainingCost,
    medicalNotes,
    remarks
  } = req.body;

  const animalCase = await AnimalCase.findById(req.params.id);
  if (!animalCase) {
    throw new AppError('Case not found.', 404);
  }

  // Authorization: reporter, assigned facility, or admin
  const isReporter = String(animalCase.reporter) === String(req.user._id);
  const isAdmin = req.user.role === 'admin';
  const isMedicalFacility = ['hospital', 'clinic', 'shelter'].includes(req.user.role);

  if (!isReporter && !isAdmin && !isMedicalFacility) {
    throw new AppError('Not authorized to update this case.', 403);
  }

  const oldStatus = animalCase.status;

  if (status && status !== oldStatus) {
    animalCase.status = status;
    // Audit status transition
    await CaseStatusHistory.create({
      caseId: animalCase._id,
      previousStatus: oldStatus,
      newStatus: status,
      changedBy: req.user._id,
      changerRole: req.user.role,
      remarks: remarks || `Status changed to ${status}`
    });

    // Notify reporter
    await NotificationService.send({
      userId: animalCase.reporter,
      title: `Case Status Updated: ${animalCase.caseId}`,
      body: `Your case status is now: ${status}`,
      category: 'Case',
      caseId: animalCase._id
    });
  }

  if (selectedFacilityId) {
    const fac = await Facility.findById(selectedFacilityId);
    if (fac) {
      animalCase.selectedFacility = fac._id;
      animalCase.selectedFacilityName = fac.name;
    }
  }

  if (volunteerAction) animalCase.volunteerAction = volunteerAction;
  if (priority) animalCase.priority = priority;
  if (estimatedCost !== undefined) animalCase.estimatedCost = estimatedCost;
  if (pawcareSupport !== undefined) animalCase.pawcareSupport = pawcareSupport;
  if (donorSupport !== undefined) animalCase.donorSupport = donorSupport;
  if (remainingCost !== undefined) animalCase.remainingCost = remainingCost;
  if (medicalNotes && Array.isArray(medicalNotes)) {
    animalCase.medicalNotes = medicalNotes;
  }

  await animalCase.save();

  return ApiResponse.success(res, 'Case updated successfully.', { case: animalCase });
});

/**
 * @desc    Delete or close an animal case
 * @route   DELETE /api/cases/:id
 * @access  Private (Reporter or Admin)
 */
const deleteCase = asyncHandler(async (req, res) => {
  const animalCase = await AnimalCase.findById(req.params.id);
  if (!animalCase) {
    throw new AppError('Case not found.', 404);
  }

  if (String(animalCase.reporter) !== String(req.user._id) && req.user.role !== 'admin') {
    throw new AppError('Only the reporter or an administrator can delete this case.', 403);
  }

  animalCase.status = 'Closed';
  await animalCase.save();

  await CaseStatusHistory.create({
    caseId: animalCase._id,
    previousStatus: animalCase.status,
    newStatus: 'Closed',
    changedBy: req.user._id,
    changerRole: req.user.role,
    remarks: 'Case marked as closed/deleted'
  });

  return ApiResponse.success(res, 'Case closed successfully.');
});

/**
 * @desc    Get status change history of a case
 * @route   GET /api/cases/:id/history
 * @access  Public / Authenticated
 */
const getCaseHistory = asyncHandler(async (req, res) => {
  const history = await CaseStatusHistory.find({ caseId: req.params.id })
    .populate('changedBy', 'fullName role')
    .sort('-createdAt');

  return ApiResponse.success(res, 'Case history retrieved.', { history });
});

module.exports = {
  createCase,
  getCases,
  getCaseById,
  updateCase,
  deleteCase,
  getCaseHistory
};

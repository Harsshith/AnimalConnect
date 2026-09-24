const TreatmentRecord = require('../models/TreatmentRecord');
const AnimalCase = require('../models/AnimalCase');
const Facility = require('../models/Facility');
const ApiResponse = require('../utils/apiResponse');
const AppError = require('../utils/appError');
const asyncHandler = require('../utils/asyncHandler');
const { processUploadedFile } = require('../config/storage');
const NotificationService = require('../services/notificationService');

/**
 * @desc    Create a new medical treatment record
 * @route   POST /api/treatments
 * @access  Private (Authorized Medical Facilities or Admin only)
 */
const createTreatment = asyncHandler(async (req, res) => {
  const {
    caseId,
    facilityId,
    veterinarianName,
    licenseNumber,
    diagnosis,
    treatmentPlan,
    medicalNotes,
    prescribedMedicines,
    estimatedCost,
    actualCost,
    treatmentStatus
  } = req.body;

  // Verify caller is a verified medical facility or admin
  const allowedRoles = ['hospital', 'clinic', 'admin'];
  if (!allowedRoles.includes(req.user.role)) {
    throw new AppError('Only authorized veterinary facilities can record medical treatments.', 403);
  }

  const animalCase = await AnimalCase.findById(caseId);
  if (!animalCase) {
    throw new AppError('Animal case not found.', 404);
  }

  const facility = await Facility.findById(facilityId);
  if (!facility) {
    throw new AppError('Facility not found.', 404);
  }

  // Process any uploaded medical documents / treatment photos
  let medicalDocuments = [];
  let treatmentPhotos = [];

  if (req.files && req.files.length > 0) {
    for (const file of req.files) {
      const processed = await processUploadedFile(file, req);
      if (processed) {
        if (file.mimetype.startsWith('image/')) {
          treatmentPhotos.push({
            url: processed.url,
            caption: 'Treatment Evidence'
          });
        } else {
          medicalDocuments.push({
            title: processed.filename,
            url: processed.url
          });
        }
      }
    }
  }

  // Parse prescribedMedicines if passed as JSON string
  let parsedMedicines = [];
  if (prescribedMedicines) {
    parsedMedicines = typeof prescribedMedicines === 'string'
      ? JSON.parse(prescribedMedicines)
      : prescribedMedicines;
  }

  // Parse medicalNotes
  let notesArray = [];
  if (medicalNotes) {
    notesArray = Array.isArray(medicalNotes)
      ? medicalNotes
      : (typeof medicalNotes === 'string' ? [medicalNotes] : []);
  }

  const treatment = await TreatmentRecord.create({
    caseId,
    facilityId,
    veterinarianName,
    licenseNumber: licenseNumber || '',
    diagnosis,
    treatmentPlan,
    medicalNotes: notesArray,
    prescribedMedicines: parsedMedicines,
    estimatedCost: parseFloat(estimatedCost) || 0,
    actualCost: parseFloat(actualCost) || 0,
    treatmentStatus: treatmentStatus || 'in_progress',
    medicalDocuments,
    treatmentPhotos,
    recordedBy: req.user._id
  });

  // Automatically update case medicalNotes, estimatedCost, and status
  if (parseFloat(estimatedCost) > 0) {
    animalCase.estimatedCost = parseFloat(estimatedCost);
    animalCase.remainingCost = Math.max(0, parseFloat(estimatedCost) - animalCase.donorSupport - animalCase.pawcareSupport);
  }
  if (notesArray.length > 0) {
    animalCase.medicalNotes.push(...notesArray);
  }
  animalCase.status = 'Under Treatment';
  await animalCase.save();

  // Notify reporter
  await NotificationService.send({
    userId: animalCase.reporter,
    title: `Medical Diagnosis Added for Case ${animalCase.caseId}`,
    body: `Dr. ${veterinarianName} diagnosed: ${diagnosis}. Treatment is underway.`,
    category: 'Case',
    caseId: animalCase._id
  });

  return ApiResponse.success(res, 'Treatment record created successfully.', { treatment }, 201);
});

/**
 * @desc    Get treatment record by ID
 * @route   GET /api/treatments/:id
 * @access  Public / Authenticated
 */
const getTreatmentById = asyncHandler(async (req, res) => {
  const treatment = await TreatmentRecord.findById(req.params.id)
    .populate('caseId')
    .populate('facilityId', 'name phone address city')
    .populate('recordedBy', 'fullName');

  if (!treatment) {
    throw new AppError('Treatment record not found.', 404);
  }

  return ApiResponse.success(res, 'Treatment details retrieved.', { treatment });
});

/**
 * @desc    Update a treatment record
 * @route   PUT /api/treatments/:id
 * @access  Private (Medical Facilities or Admin)
 */
const updateTreatment = asyncHandler(async (req, res) => {
  const treatment = await TreatmentRecord.findById(req.params.id);
  if (!treatment) {
    throw new AppError('Treatment record not found.', 404);
  }

  const allowedRoles = ['hospital', 'clinic', 'admin'];
  if (!allowedRoles.includes(req.user.role)) {
    throw new AppError('Only medical facilities can update treatment records.', 403);
  }

  const {
    diagnosis,
    treatmentPlan,
    medicalNotes,
    treatmentStatus,
    actualCost,
    prescribedMedicines
  } = req.body;

  if (diagnosis) treatment.diagnosis = diagnosis;
  if (treatmentPlan) treatment.treatmentPlan = treatmentPlan;
  if (treatmentStatus) treatment.treatmentStatus = treatmentStatus;
  if (actualCost !== undefined) treatment.actualCost = parseFloat(actualCost);
  if (medicalNotes && Array.isArray(medicalNotes)) {
    treatment.medicalNotes.push(...medicalNotes);
  }
  if (prescribedMedicines && Array.isArray(prescribedMedicines)) {
    treatment.prescribedMedicines = prescribedMedicines;
  }

  // If treatment completed, update linked animal case
  if (treatmentStatus === 'completed') {
    const animalCase = await AnimalCase.findById(treatment.caseId);
    if (animalCase) {
      animalCase.status = 'Treatment Completed';
      await animalCase.save();
    }
  }

  await treatment.save();
  return ApiResponse.success(res, 'Treatment record updated.', { treatment });
});

/**
 * @desc    Get all treatments for a specific animal case
 * @route   GET /api/cases/:id/treatments
 * @access  Public / Authenticated
 */
const getTreatmentsForCase = asyncHandler(async (req, res) => {
  const treatments = await TreatmentRecord.find({ caseId: req.params.id })
    .populate('facilityId', 'name phone address city')
    .sort('-createdAt');

  return ApiResponse.success(res, 'Case treatments retrieved.', { treatments });
});

module.exports = {
  createTreatment,
  getTreatmentById,
  updateTreatment,
  getTreatmentsForCase
};

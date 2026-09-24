const AdoptionAnimal = require('../models/AdoptionAnimal');
const AdoptionApplication = require('../models/AdoptionApplication');
const Facility = require('../models/Facility');
const ApiResponse = require('../utils/apiResponse');
const AppError = require('../utils/appError');
const asyncHandler = require('../utils/asyncHandler');
const { generateApplicationId } = require('../utils/idGenerator');
const { processUploadedFile } = require('../config/storage');
const NotificationService = require('../services/notificationService');

/**
 * @desc    Publish a new animal for adoption
 * @route   POST /api/adoption/animals
 * @access  Private (Shelter or Admin only)
 */
const publishAnimal = asyncHandler(async (req, res) => {
  const {
    name,
    animalType,
    breed,
    age,
    gender,
    isVaccinated,
    isSterilized,
    location,
    shelter: shelterId,
    story,
    personality,
    healthSummary,
    imageUrl
  } = req.body;

  const allowedRoles = ['shelter', 'admin'];
  if (!allowedRoles.includes(req.user.role)) {
    throw new AppError('Only registered shelters can list animals for adoption.', 403);
  }

  const shelter = await Facility.findById(shelterId);
  if (!shelter) {
    throw new AppError('Shelter not found.', 404);
  }

  let finalImageUrl = imageUrl || 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=600';
  if (req.file) {
    const uploaded = await processUploadedFile(req.file, req);
    if (uploaded) finalImageUrl = uploaded.url;
  }

  let parsedPersonality = personality;
  if (typeof personality === 'string') {
    try {
      parsedPersonality = JSON.parse(personality);
    } catch (e) {
      parsedPersonality = personality.split(',').map((p) => p.trim());
    }
  }

  const animal = await AdoptionAnimal.create({
    name,
    animalType,
    breed: breed || 'Mixed / Indie',
    age: age || '1 Year',
    gender: gender || 'Unknown',
    isVaccinated: isVaccinated !== undefined ? Boolean(isVaccinated) : true,
    isSterilized: isSterilized !== undefined ? Boolean(isSterilized) : true,
    location: location || shelter.city,
    shelter: shelter._id,
    shelterName: shelter.name,
    story: story || '',
    personality: Array.isArray(parsedPersonality) ? parsedPersonality : ['Friendly', 'Playful'],
    healthSummary: healthSummary || 'Vaccinated and healthy.',
    imageUrl: finalImageUrl,
    addedBy: req.user._id
  });

  return ApiResponse.success(res, 'Animal listed for adoption successfully.', { animal }, 201);
});

/**
 * @desc    Get all adoption animals
 * @route   GET /api/adoption/animals
 * @access  Public
 */
const getAnimals = asyncHandler(async (req, res) => {
  const { animalType, gender, isAdopted, status, search, shelterId } = req.query;

  const query = {};
  if (animalType) query.animalType = new RegExp(animalType, 'i');
  if (gender) query.gender = gender;
  if (isAdopted !== undefined) query.isAdopted = isAdopted === 'true';
  if (status) query.status = status;
  if (shelterId) query.shelter = shelterId;

  if (search) {
    query.$or = [
      { name: new RegExp(search, 'i') },
      { breed: new RegExp(search, 'i') },
      { location: new RegExp(search, 'i') },
      { shelterName: new RegExp(search, 'i') }
    ];
  }

  const animals = await AdoptionAnimal.find(query)
    .populate('shelter', 'name phone address city')
    .sort('-createdAt');

  return ApiResponse.success(res, 'Adoption animals retrieved.', { animals });
});

/**
 * @desc    Get adoption animal by ID
 * @route   GET /api/adoption/animals/:id
 * @access  Public
 */
const getAnimalById = asyncHandler(async (req, res) => {
  const animal = await AdoptionAnimal.findById(req.params.id).populate(
    'shelter',
    'name phone address city openHours'
  );
  if (!animal) {
    throw new AppError('Adoption animal not found.', 404);
  }

  return ApiResponse.success(res, 'Animal details retrieved.', { animal });
});

/**
 * @desc    Update adoption animal profile
 * @route   PUT /api/adoption/animals/:id
 * @access  Private (Shelter or Admin)
 */
const updateAnimal = asyncHandler(async (req, res) => {
  const animal = await AdoptionAnimal.findById(req.params.id);
  if (!animal) {
    throw new AppError('Animal not found.', 404);
  }

  const allowedRoles = ['shelter', 'admin'];
  if (!allowedRoles.includes(req.user.role)) {
    throw new AppError('Not authorized to modify adoption profiles.', 403);
  }

  const {
    name,
    breed,
    age,
    gender,
    isVaccinated,
    isSterilized,
    story,
    healthSummary,
    status,
    isAdopted
  } = req.body;

  if (name) animal.name = name;
  if (breed) animal.breed = breed;
  if (age) animal.age = age;
  if (gender) animal.gender = gender;
  if (isVaccinated !== undefined) animal.isVaccinated = Boolean(isVaccinated);
  if (isSterilized !== undefined) animal.isSterilized = Boolean(isSterilized);
  if (story !== undefined) animal.story = story;
  if (healthSummary !== undefined) animal.healthSummary = healthSummary;
  if (status) animal.status = status;
  if (isAdopted !== undefined) {
    animal.isAdopted = Boolean(isAdopted);
    if (animal.isAdopted) animal.status = 'Adopted';
  }

  await animal.save();
  return ApiResponse.success(res, 'Animal profile updated.', { animal });
});

/**
 * @desc    Submit adoption application
 * @route   POST /api/adoption/applications
 * @access  Private
 */
const submitApplication = asyncHandler(async (req, res) => {
  const {
    animalId,
    applicantName,
    applicantPhone,
    applicantEmail,
    livingSituation,
    petExperience,
    reason
  } = req.body;

  const animal = await AdoptionAnimal.findById(animalId);
  if (!animal) {
    throw new AppError('Adoption animal not found.', 404);
  }

  if (animal.isAdopted || animal.status === 'Adopted') {
    throw new AppError('This animal has already been adopted.', 400);
  }

  const applicationId = generateApplicationId();

  const application = await AdoptionApplication.create({
    applicationId,
    animalId: animal._id,
    animalName: animal.name,
    applicant: req.user._id,
    applicantName: applicantName || req.user.fullName,
    applicantPhone: applicantPhone || req.user.phone,
    applicantEmail: applicantEmail || req.user.email,
    livingSituation,
    petExperience,
    reason,
    status: 'Submitted'
  });

  // Update animal status to Application Under Review
  animal.status = 'Application Under Review';
  await animal.save();

  // Notify applicant
  await NotificationService.send({
    userId: req.user._id,
    title: `Adoption Application Submitted (${applicationId})`,
    body: `Your application to adopt ${animal.name} has been sent to ${animal.shelterName}.`,
    category: 'Adoption'
  });

  return ApiResponse.success(
    res,
    'Adoption application submitted successfully.',
    { application },
    201
  );
});

/**
 * @desc    Get current user's adoption applications
 * @route   GET /api/adoption/applications/my
 * @access  Private
 */
const getMyApplications = asyncHandler(async (req, res) => {
  const applications = await AdoptionApplication.find({ applicant: req.user._id })
    .populate('animalId')
    .sort('-createdAt');

  return ApiResponse.success(res, 'Applications retrieved.', { applications });
});

/**
 * @desc    Update adoption application status (Shelter or Admin review)
 * @route   PUT /api/adoption/applications/:id
 * @access  Private (Shelter or Admin)
 */
const updateApplicationStatus = asyncHandler(async (req, res) => {
  const { status, reviewNotes } = req.body;

  const application = await AdoptionApplication.findById(req.params.id);
  if (!application) {
    throw new AppError('Application not found.', 404);
  }

  const allowedRoles = ['shelter', 'admin'];
  if (!allowedRoles.includes(req.user.role)) {
    throw new AppError('Only shelter managers or administrators can review applications.', 403);
  }

  application.status = status;
  if (reviewNotes) application.reviewNotes = reviewNotes;
  application.reviewedBy = req.user._id;
  application.reviewedAt = new Date();
  await application.save();

  // If approved, update animal to Adopted
  if (status === 'Approved') {
    const animal = await AdoptionAnimal.findById(application.animalId);
    if (animal) {
      animal.isAdopted = true;
      animal.status = 'Adopted';
      await animal.save();
    }
  }

  // Notify applicant
  await NotificationService.send({
    userId: application.applicant,
    title: `Adoption Application Update`,
    body: `Your application for ${application.animalName} is now: ${status}.`,
    category: 'Adoption'
  });

  return ApiResponse.success(res, 'Application status updated.', { application });
});

module.exports = {
  publishAnimal,
  getAnimals,
  getAnimalById,
  updateAnimal,
  submitApplication,
  getMyApplications,
  updateApplicationStatus
};

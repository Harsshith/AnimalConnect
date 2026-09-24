const express = require('express');
const router = express.Router();
const facilityController = require('../controllers/facilityController');
const { protect, optionalAuth } = require('../middleware/authMiddleware');
const { uploadSingle } = require('../middleware/uploadMiddleware');
const validate = require('../middleware/validationMiddleware');
const {
  registerFacilityValidator,
  nearbyFacilityValidator
} = require('../validators/facilityValidators');

// Hospitals & Clinics registration
router.post(
  '/hospitals/register',
  protect,
  uploadSingle('document'),
  registerFacilityValidator,
  validate,
  facilityController.registerHospital
);

router.post(
  '/clinics/register',
  protect,
  uploadSingle('document'),
  registerFacilityValidator,
  validate,
  facilityController.registerClinic
);

// Filtered GETs
router.get('/hospitals', (req, res, next) => {
  req.query.type = 'hospital';
  return facilityController.getFacilities(req, res, next);
});

router.get('/clinics', (req, res, next) => {
  req.query.type = 'clinic';
  return facilityController.getFacilities(req, res, next);
});

// Geospatial search
router.get('/nearby', nearbyFacilityValidator, validate, facilityController.getNearbyFacilities);

// Facility CRUD & Cases
router.get('/', optionalAuth, facilityController.getFacilities);
router.get('/:id', optionalAuth, facilityController.getFacilityById);
router.put('/:id', protect, uploadSingle('image'), facilityController.updateFacility);
router.get('/:id/cases', protect, facilityController.getFacilityCases);
router.post('/:id/cases/:caseId/accept', protect, facilityController.acceptCase);

module.exports = router;

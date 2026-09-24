const express = require('express');
const router = express.Router();
const shelterController = require('../controllers/shelterController');
const { protect, optionalAuth } = require('../middleware/authMiddleware');
const validate = require('../middleware/validationMiddleware');
const { registerFacilityValidator } = require('../validators/facilityValidators');

router.post('/register', protect, registerFacilityValidator, validate, shelterController.registerShelter);
router.get('/', optionalAuth, shelterController.getShelters);
router.get('/:id', optionalAuth, shelterController.getShelterById);
router.put('/:id', protect, shelterController.updateShelter);
router.post('/:id/admission-requests', protect, shelterController.requestAdmission);

module.exports = router;

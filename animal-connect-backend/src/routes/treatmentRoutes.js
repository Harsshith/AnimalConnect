const express = require('express');
const router = express.Router();
const treatmentController = require('../controllers/treatmentController');
const { protect, optionalAuth } = require('../middleware/authMiddleware');
const { uploadMultiple } = require('../middleware/uploadMiddleware');
const validate = require('../middleware/validationMiddleware');
const { createTreatmentValidator } = require('../validators/treatmentValidators');

router.post(
  '/',
  protect,
  uploadMultiple('documents', 5),
  createTreatmentValidator,
  validate,
  treatmentController.createTreatment
);

router.get('/:id', optionalAuth, treatmentController.getTreatmentById);
router.put('/:id', protect, treatmentController.updateTreatment);

module.exports = router;

const express = require('express');
const router = express.Router();
const caseController = require('../controllers/caseController');
const treatmentController = require('../controllers/treatmentController');
const { protect, optionalAuth } = require('../middleware/authMiddleware');
const { uploadMultiple } = require('../middleware/uploadMiddleware');
const validate = require('../middleware/validationMiddleware');
const { createCaseValidator, updateCaseValidator } = require('../validators/caseValidators');

router.post(
  '/',
  protect,
  uploadMultiple('images', 5),
  createCaseValidator,
  validate,
  caseController.createCase
);

router.get('/', optionalAuth, caseController.getCases);
router.get('/:id', optionalAuth, caseController.getCaseById);
router.put('/:id', protect, updateCaseValidator, validate, caseController.updateCase);
router.delete('/:id', protect, caseController.deleteCase);
router.get('/:id/history', caseController.getCaseHistory);
router.get('/:id/treatments', optionalAuth, treatmentController.getTreatmentsForCase);

module.exports = router;

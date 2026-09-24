const express = require('express');
const router = express.Router();
const fundingController = require('../controllers/fundingController');
const { protect, optionalAuth } = require('../middleware/authMiddleware');
const validate = require('../middleware/validationMiddleware');
const { createFundingRequestValidator } = require('../validators/fundingValidators');

router.post('/', protect, createFundingRequestValidator, validate, fundingController.createFundingRequest);
router.get('/', optionalAuth, fundingController.getFundingRequests);
router.get('/:id', optionalAuth, fundingController.getFundingRequestById);
router.post('/:id/submit', protect, fundingController.submitFundingRequest);
router.put('/:id/review', protect, fundingController.reviewFundingRequest);

module.exports = router;

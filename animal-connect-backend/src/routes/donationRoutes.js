const express = require('express');
const router = express.Router();
const donationController = require('../controllers/donationController');
const { protect, optionalAuth } = require('../middleware/authMiddleware');
const validate = require('../middleware/validationMiddleware');
const { createDonationValidator } = require('../validators/donationValidators');

router.get('/cases', donationController.getEligibleCases);
router.post('/', optionalAuth, createDonationValidator, validate, donationController.createDonation);
router.get('/my', protect, donationController.getMyDonations);
router.get('/:id', optionalAuth, donationController.getDonationById);

module.exports = router;

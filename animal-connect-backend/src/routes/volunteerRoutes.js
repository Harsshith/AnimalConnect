const express = require('express');
const router = express.Router();
const volunteerController = require('../controllers/volunteerController');
const { protect } = require('../middleware/authMiddleware');

router.post('/profile', protect, volunteerController.createOrUpdateProfile);
router.get('/profile', protect, volunteerController.getMyProfile);
router.put('/profile', protect, volunteerController.updateProfile);
router.put('/availability', protect, volunteerController.updateAvailability);

module.exports = router;

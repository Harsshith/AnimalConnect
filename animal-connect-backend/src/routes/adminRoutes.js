const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const photoVerificationController = require('../controllers/photoVerificationController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

// All routes in this router are restricted to Admin
router.use(protect, authorize('admin'));

router.get('/facilities/pending', adminController.getPendingFacilities);
router.put('/facilities/:id/verify', adminController.verifyFacility);
router.get('/stats', adminController.getPlatformStats);
router.get('/audit-logs', adminController.getAuditLogs);
router.put('/users/:id/status', adminController.updateUserStatus);
router.get('/photo-verification/:caseId', photoVerificationController.getComparison);
router.put('/photo-verification/:caseId', photoVerificationController.submitDecision);

module.exports = router;

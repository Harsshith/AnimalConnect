const express = require('express');
const router = express.Router();

const authRoutes = require('./authRoutes');
const volunteerRoutes = require('./volunteerRoutes');
const caseRoutes = require('./caseRoutes');
const facilityRoutes = require('./facilityRoutes');
const shelterRoutes = require('./shelterRoutes');
const petCareRoutes = require('./petCareRoutes');
const treatmentRoutes = require('./treatmentRoutes');
const fundingRoutes = require('./fundingRoutes');
const donationRoutes = require('./donationRoutes');
const medicineRoutes = require('./medicineRoutes');
const adoptionRoutes = require('./adoptionRoutes');
const notificationRoutes = require('./notificationRoutes');
const adminRoutes = require('./adminRoutes');

const shelterController = require('../controllers/shelterController');
const photoVerificationController = require('../controllers/photoVerificationController');
const medicineController = require('../controllers/medicineController');
const { protect } = require('../middleware/authMiddleware');
const { uploadSingle } = require('../middleware/uploadMiddleware');
const validate = require('../middleware/validationMiddleware');
const { createMedicineOrderValidator } = require('../validators/medicineValidators');

// Mount Sub-routers
router.use('/auth', authRoutes);
router.use('/volunteers', volunteerRoutes);
router.use('/cases', caseRoutes);
router.use('/facilities', facilityRoutes);
router.use('/shelters', shelterRoutes);
router.use('/pet-care', petCareRoutes);
router.use('/treatments', treatmentRoutes);
router.use('/funding-requests', fundingRoutes);
router.use('/donations', donationRoutes);
router.use('/medicines', medicineRoutes);
router.use('/adoption', adoptionRoutes);
router.use('/notifications', notificationRoutes);
router.use('/admin', adminRoutes);

// Direct top-level helper routes matching API specification in prompt
router.put('/admission-requests/:id', protect, shelterController.updateAdmissionRequest);

// Medicine order top-level routes matching prompt
router.post(
  '/medicine-orders',
  protect,
  uploadSingle('prescription'),
  createMedicineOrderValidator,
  validate,
  medicineController.createMedicineOrder
);
router.get('/medicine-orders/my', protect, medicineController.getMyMedicineOrders);
router.get('/medicine-orders/:id', protect, medicineController.getMedicineOrderById);
router.put('/medicine-orders/:id', protect, medicineController.updateOrderStatus);
router.get('/medicine-providers', medicineController.getMedicineProviders);

// Top-level photo-verification routes
router.get('/photo-verification/:caseId', protect, photoVerificationController.getComparison);
router.put('/photo-verification/:caseId', protect, photoVerificationController.submitDecision);

// System Health Check
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Animal Connect API is healthy and operational.',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

module.exports = router;

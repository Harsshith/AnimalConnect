const express = require('express');
const router = express.Router();
const medicineController = require('../controllers/medicineController');
const { protect, optionalAuth } = require('../middleware/authMiddleware');
const { uploadSingle } = require('../middleware/uploadMiddleware');
const validate = require('../middleware/validationMiddleware');
const { createMedicineOrderValidator } = require('../validators/medicineValidators');

// Catalog & Providers
router.get('/', medicineController.getMedicines);
router.get('/providers', medicineController.getMedicineProviders);

// Orders
router.post(
  '/orders',
  protect,
  uploadSingle('prescription'),
  createMedicineOrderValidator,
  validate,
  medicineController.createMedicineOrder
);
router.get('/orders/my', protect, medicineController.getMyMedicineOrders);
router.get('/orders/:id', protect, medicineController.getMedicineOrderById);
router.put('/orders/:id', protect, medicineController.updateOrderStatus);

module.exports = router;

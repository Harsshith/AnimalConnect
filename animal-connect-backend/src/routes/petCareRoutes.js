const express = require('express');
const router = express.Router();
const petCareController = require('../controllers/petCareController');
const { protect, optionalAuth } = require('../middleware/authMiddleware');

router.post('/register', protect, petCareController.registerProvider);
router.get('/', optionalAuth, petCareController.getProviders);
router.get('/:id', optionalAuth, petCareController.getProviderById);
router.put('/:id', protect, petCareController.updateProvider);
router.post('/:id/book', protect, petCareController.bookProvider);

module.exports = router;

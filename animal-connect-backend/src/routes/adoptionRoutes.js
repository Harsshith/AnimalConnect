const express = require('express');
const router = express.Router();
const adoptionController = require('../controllers/adoptionController');
const { protect, optionalAuth } = require('../middleware/authMiddleware');
const { uploadSingle } = require('../middleware/uploadMiddleware');
const validate = require('../middleware/validationMiddleware');
const {
  createAdoptionAnimalValidator,
  createAdoptionApplicationValidator
} = require('../validators/adoptionValidators');

// Adoption animals
router.post(
  '/animals',
  protect,
  uploadSingle('image'),
  createAdoptionAnimalValidator,
  validate,
  adoptionController.publishAnimal
);
router.get('/animals', optionalAuth, adoptionController.getAnimals);
router.get('/animals/:id', optionalAuth, adoptionController.getAnimalById);
router.put('/animals/:id', protect, adoptionController.updateAnimal);

// Adoption applications
router.post(
  '/applications',
  protect,
  createAdoptionApplicationValidator,
  validate,
  adoptionController.submitApplication
);
router.get('/applications/my', protect, adoptionController.getMyApplications);
router.put('/applications/:id', protect, adoptionController.updateApplicationStatus);

module.exports = router;

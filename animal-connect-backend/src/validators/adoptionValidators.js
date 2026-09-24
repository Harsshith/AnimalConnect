const { body } = require('express-validator');

const createAdoptionAnimalValidator = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('Animal name is required'),
  body('animalType')
    .trim()
    .notEmpty()
    .withMessage('Animal type is required (Dog, Cat, Other)'),
  body('shelter')
    .notEmpty()
    .withMessage('Shelter ID is required')
    .isMongoId()
    .withMessage('Invalid Shelter ID format'),
  body('location')
    .trim()
    .notEmpty()
    .withMessage('Location is required')
];

const createAdoptionApplicationValidator = [
  body('animalId')
    .notEmpty()
    .withMessage('Animal ID is required')
    .isMongoId()
    .withMessage('Invalid Animal ID format'),
  body('applicantName')
    .trim()
    .notEmpty()
    .withMessage('Applicant name is required'),
  body('applicantPhone')
    .trim()
    .notEmpty()
    .withMessage('Applicant phone is required'),
  body('livingSituation')
    .trim()
    .notEmpty()
    .withMessage('Living situation details are required'),
  body('petExperience')
    .trim()
    .notEmpty()
    .withMessage('Pet experience details are required'),
  body('reason')
    .trim()
    .notEmpty()
    .withMessage('Reason for adoption is required')
];

module.exports = {
  createAdoptionAnimalValidator,
  createAdoptionApplicationValidator
};

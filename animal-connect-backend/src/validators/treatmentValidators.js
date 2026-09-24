const { body, param } = require('express-validator');

const createTreatmentValidator = [
  body('caseId')
    .notEmpty()
    .withMessage('Case ID is required')
    .isMongoId()
    .withMessage('Invalid Case ID format'),
  body('facilityId')
    .notEmpty()
    .withMessage('Facility ID is required')
    .isMongoId()
    .withMessage('Invalid Facility ID format'),
  body('veterinarianName')
    .trim()
    .notEmpty()
    .withMessage('Veterinarian name is required'),
  body('diagnosis')
    .trim()
    .notEmpty()
    .withMessage('Diagnosis is required'),
  body('treatmentPlan')
    .trim()
    .notEmpty()
    .withMessage('Treatment plan is required'),
  body('estimatedCost')
    .notEmpty()
    .withMessage('Estimated cost is required')
    .isFloat({ min: 0 })
    .withMessage('Estimated cost must be a positive number')
];

module.exports = {
  createTreatmentValidator
};

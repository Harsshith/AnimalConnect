const { body } = require('express-validator');

const createFundingRequestValidator = [
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
  body('diagnosis')
    .trim()
    .notEmpty()
    .withMessage('Diagnosis is required'),
  body('treatmentDetails')
    .trim()
    .notEmpty()
    .withMessage('Treatment details are required'),
  body('requestedAmount')
    .notEmpty()
    .withMessage('Requested amount is required')
    .isFloat({ min: 1 })
    .withMessage('Requested amount must be at least 1')
];

module.exports = {
  createFundingRequestValidator
};

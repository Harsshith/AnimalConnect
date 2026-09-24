const { body, param, query } = require('express-validator');

const createCaseValidator = [
  body('animalType')
    .trim()
    .notEmpty()
    .withMessage('Animal type is required (e.g. Dog, Cat, Other)'),
  body('condition')
    .notEmpty()
    .withMessage('Condition is required')
    .isIn(['Critical', 'Injured', 'Sick', 'Healthy', 'Abandoned', 'Puppy/Kitten'])
    .withMessage('Invalid animal condition specified'),
  body('description')
    .trim()
    .notEmpty()
    .withMessage('Description is required')
    .isLength({ min: 10 })
    .withMessage('Description must be at least 10 characters long'),
  body('locationAddress')
    .trim()
    .notEmpty()
    .withMessage('Location address is required'),
  body('ageGroup')
    .optional()
    .isIn(['Young', 'Adult', 'Senior', 'Unknown'])
    .withMessage('Invalid age group'),
  body('priority')
    .optional()
    .isIn(['Low', 'Medium', 'High', 'Critical'])
    .withMessage('Invalid priority level')
];

const updateCaseValidator = [
  param('id')
    .isMongoId()
    .withMessage('Invalid case ID parameter'),
  body('status')
    .optional()
    .isIn([
      'Reported',
      'Facility Selected',
      'Admitted',
      'Under Treatment',
      'Funding Review',
      'Treatment Completed',
      'Shelter Care',
      'Ready for Adoption',
      'Adopted',
      'Closed'
    ])
    .withMessage('Invalid case status')
];

module.exports = {
  createCaseValidator,
  updateCaseValidator
};

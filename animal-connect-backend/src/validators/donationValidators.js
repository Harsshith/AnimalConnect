const { body } = require('express-validator');

const createDonationValidator = [
  body('amount')
    .notEmpty()
    .withMessage('Donation amount is required')
    .isFloat({ min: 1 })
    .withMessage('Donation amount must be at least 1'),
  body('donorName')
    .trim()
    .notEmpty()
    .withMessage('Donor name is required'),
  body('category')
    .optional()
    .isIn(['Emergency Treatment', 'Shelter Care', 'Medicine Support', 'General Animal Care'])
    .withMessage('Invalid donation category')
];

module.exports = {
  createDonationValidator
};

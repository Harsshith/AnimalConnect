const { body } = require('express-validator');

const createMedicineOrderValidator = [
  body('items')
    .isArray({ min: 1 })
    .withMessage('Order must contain at least one item'),
  body('items.*.name')
    .notEmpty()
    .withMessage('Medicine item name is required'),
  body('items.*.price')
    .isFloat({ min: 0 })
    .withMessage('Medicine item price must be positive'),
  body('items.*.quantity')
    .isInt({ min: 1 })
    .withMessage('Quantity must be at least 1'),
  body('deliveryAddress')
    .trim()
    .notEmpty()
    .withMessage('Delivery address is required')
];

module.exports = {
  createMedicineOrderValidator
};

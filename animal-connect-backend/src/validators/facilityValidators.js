const { body, param, query } = require('express-validator');

const registerFacilityValidator = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('Facility name is required'),
  body('phone')
    .trim()
    .notEmpty()
    .withMessage('Contact phone number is required'),
  body('address')
    .trim()
    .notEmpty()
    .withMessage('Address is required'),
  body('city')
    .trim()
    .notEmpty()
    .withMessage('City is required')
];

const nearbyFacilityValidator = [
  query('latitude')
    .notEmpty()
    .withMessage('Latitude is required')
    .isFloat({ min: -90, max: 90 })
    .withMessage('Latitude must be between -90 and 90'),
  query('longitude')
    .notEmpty()
    .withMessage('Longitude is required')
    .isFloat({ min: -180, max: 180 })
    .withMessage('Longitude must be between -180 and 180'),
  query('radius')
    .optional()
    .isFloat({ min: 0.1, max: 500 })
    .withMessage('Radius must be between 0.1 and 500 km')
];

module.exports = {
  registerFacilityValidator,
  nearbyFacilityValidator
};

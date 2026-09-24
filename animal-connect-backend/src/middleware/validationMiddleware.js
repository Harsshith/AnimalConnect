const { validationResult } = require('express-validator');
const ApiResponse = require('../utils/apiResponse');

/**
 * Validates request schema via express-validator rules
 */
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    const formattedErrors = errors.array().map((err) => ({
      field: err.path || err.param,
      message: err.msg
    }));

    return ApiResponse.error(
      res,
      'Validation failed: Please verify the submitted data.',
      formattedErrors,
      400
    );
  }
  next();
};

module.exports = validate;

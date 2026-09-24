/**
 * Standardized API Response helper
 */
class ApiResponse {
  static success(res, message = 'Success', data = {}, statusCode = 200) {
    return res.status(statusCode).json({
      success: true,
      message,
      data
    });
  }

  static error(res, message = 'An error occurred', errors = [], statusCode = 500) {
    return res.status(statusCode).json({
      success: false,
      message,
      errors: Array.isArray(errors) ? errors : [errors]
    });
  }

  static paginated(res, message = 'Success', items = [], pagination = {}, statusCode = 200) {
    return res.status(statusCode).json({
      success: true,
      message,
      data: {
        items,
        pagination: {
          total: pagination.total || items.length,
          page: pagination.page || 1,
          limit: pagination.limit || items.length,
          totalPages: pagination.totalPages || 1
        }
      }
    });
  }
}

module.exports = ApiResponse;

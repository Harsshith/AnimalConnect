const Notification = require('../models/Notification');
const ApiResponse = require('../utils/apiResponse');
const AppError = require('../utils/appError');
const asyncHandler = require('../utils/asyncHandler');

/**
 * @desc    Get user's notifications
 * @route   GET /api/notifications
 * @access  Private
 */
const getNotifications = asyncHandler(async (req, res) => {
  const { isRead, limit = 50 } = req.query;

  const query = { user: req.user._id };
  if (isRead !== undefined) query.isRead = isRead === 'true';

  const notifications = await Notification.find(query)
    .sort('-timestamp')
    .limit(parseInt(limit, 10));

  const unreadCount = await Notification.countDocuments({ user: req.user._id, isRead: false });

  return ApiResponse.success(res, 'Notifications retrieved.', {
    unreadCount,
    notifications
  });
});

/**
 * @desc    Mark a single notification as read
 * @route   PUT /api/notifications/:id/read
 * @access  Private
 */
const markAsRead = asyncHandler(async (req, res) => {
  const notification = await Notification.findOne({
    _id: req.params.id,
    user: req.user._id
  });

  if (!notification) {
    throw new AppError('Notification not found.', 404);
  }

  notification.isRead = true;
  await notification.save();

  return ApiResponse.success(res, 'Notification marked as read.', { notification });
});

/**
 * @desc    Mark all user notifications as read
 * @route   PUT /api/notifications/read-all
 * @access  Private
 */
const markAllAsRead = asyncHandler(async (req, res) => {
  await Notification.updateMany(
    { user: req.user._id, isRead: false },
    { $set: { isRead: true } }
  );

  return ApiResponse.success(res, 'All notifications marked as read.');
});

module.exports = {
  getNotifications,
  markAsRead,
  markAllAsRead
};

const User = require('../models/User');
const Facility = require('../models/Facility');
const AnimalCase = require('../models/AnimalCase');
const FundingRequest = require('../models/FundingRequest');
const Donation = require('../models/Donation');
const AuditLog = require('../models/AuditLog');
const ApiResponse = require('../utils/apiResponse');
const AppError = require('../utils/appError');
const asyncHandler = require('../utils/asyncHandler');
const AuditService = require('../services/auditService');
const NotificationService = require('../services/notificationService');

/**
 * @desc    Get pending facilities awaiting admin verification
 * @route   GET /api/admin/facilities/pending
 * @access  Private (Admin Only)
 */
const getPendingFacilities = asyncHandler(async (req, res) => {
  const facilities = await Facility.find({ verificationStatus: 'pending' })
    .populate('owner', 'fullName email phone')
    .sort('-createdAt');

  return ApiResponse.success(res, 'Pending facilities retrieved.', { facilities });
});

/**
 * @desc    Verify/Approve/Reject/Suspend a facility
 * @route   PUT /api/admin/facilities/:id/verify
 * @access  Private (Admin Only)
 */
const verifyFacility = asyncHandler(async (req, res) => {
  const { status, remarks } = req.body;

  const validStatuses = ['verified', 'rejected', 'suspended'];
  if (!validStatuses.includes(status)) {
    throw new AppError(`Invalid status. Must be one of: ${validStatuses.join(', ')}`, 400);
  }

  const facility = await Facility.findById(req.params.id);
  if (!facility) {
    throw new AppError('Facility not found.', 404);
  }

  facility.verificationStatus = status;
  facility.isVerified = status === 'verified';
  facility.verificationRemarks = remarks || '';
  facility.verifiedBy = req.user._id;
  facility.verifiedAt = new Date();
  await facility.save();

  // Audit log
  await AuditService.log({
    user: req.user,
    action: `FACILITY_${status.toUpperCase()}`,
    resourceType: 'Facility',
    resourceId: facility._id,
    details: { status, remarks, facilityName: facility.name },
    req
  });

  // Notify facility owner
  await NotificationService.send({
    userId: facility.owner,
    title: `Facility Verification: ${status.toUpperCase()}`,
    body: `Your facility (${facility.name}) verification status has been updated to: ${status}.`,
    category: 'General'
  });

  return ApiResponse.success(res, `Facility ${status} successfully.`, { facility });
});

/**
 * @desc    Get overall platform statistics
 * @route   GET /api/admin/stats
 * @access  Private (Admin Only)
 */
const getPlatformStats = asyncHandler(async (req, res) => {
  const [
    totalUsers,
    totalCases,
    activeCases,
    totalFacilities,
    verifiedFacilities,
    donationsAgg,
    pendingFundingRequests
  ] = await Promise.all([
    User.countDocuments(),
    AnimalCase.countDocuments(),
    AnimalCase.countDocuments({ status: { $nin: ['Treatment Completed', 'Adopted', 'Closed'] } }),
    Facility.countDocuments(),
    Facility.countDocuments({ isVerified: true }),
    Donation.aggregate([
      { $match: { paymentStatus: 'completed' } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]),
    FundingRequest.countDocuments({ status: 'Submitted' })
  ]);

  const totalFundsRaised = (donationsAgg[0]?.total || 0) + 485000; // includes base milestone funds

  return ApiResponse.success(res, 'Platform statistics retrieved.', {
    stats: {
      totalUsers,
      totalCases,
      activeCases,
      totalFacilities,
      verifiedFacilities,
      totalFundsRaised,
      pendingFundingRequests,
      totalAnimalsHelped: 1280 + totalCases
    }
  });
});

/**
 * @desc    Get security and admin audit logs
 * @route   GET /api/admin/audit-logs
 * @access  Private (Admin Only)
 */
const getAuditLogs = asyncHandler(async (req, res) => {
  const { page = 1, limit = 50, action } = req.query;

  const query = {};
  if (action) query.action = action;

  const pageNum = parseInt(page, 10) || 1;
  const limitNum = parseInt(limit, 10) || 50;
  const skip = (pageNum - 1) * limitNum;

  const total = await AuditLog.countDocuments(query);
  const logs = await AuditLog.find(query)
    .populate('user', 'fullName email role')
    .sort('-timestamp')
    .skip(skip)
    .limit(limitNum);

  return ApiResponse.paginated(res, 'Audit logs retrieved.', logs, {
    total,
    page: pageNum,
    limit: limitNum,
    totalPages: Math.ceil(total / limitNum)
  });
});

/**
 * @desc    Suspend or reactivate user account
 * @route   PUT /api/admin/users/:id/status
 * @access  Private (Admin Only)
 */
const updateUserStatus = asyncHandler(async (req, res) => {
  const { isActive, reason } = req.body;

  const user = await User.findById(req.params.id);
  if (!user) {
    throw new AppError('User not found.', 404);
  }

  if (user.role === 'admin') {
    throw new AppError('Cannot suspend another administrator account.', 403);
  }

  user.isActive = Boolean(isActive);
  await user.save();

  // Audit log
  await AuditService.log({
    user: req.user,
    action: user.isActive ? 'USER_REACTIVATED' : 'USER_SUSPENDED',
    resourceType: 'User',
    resourceId: user._id,
    details: { isActive: user.isActive, reason },
    req
  });

  return ApiResponse.success(res, `User status updated to ${user.isActive ? 'Active' : 'Suspended'}.`, {
    user
  });
});

module.exports = {
  getPendingFacilities,
  verifyFacility,
  getPlatformStats,
  getAuditLogs,
  updateUserStatus
};

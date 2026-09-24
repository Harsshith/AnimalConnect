const PhotoVerificationService = require('../services/photoVerificationService');
const ApiResponse = require('../utils/apiResponse');
const asyncHandler = require('../utils/asyncHandler');
const AuditService = require('../services/auditService');

/**
 * @desc    Get photo verification comparison details for a case
 * @route   GET /api/photo-verification/:caseId
 * @access  Private (Admin or Facility)
 */
const getComparison = asyncHandler(async (req, res) => {
  const comparison = await PhotoVerificationService.getVerificationComparison(req.params.caseId);
  return ApiResponse.success(res, 'Photo verification comparison retrieved.', { comparison });
});

/**
 * @desc    Submit photo verification review decision
 * @route   PUT /api/photo-verification/:caseId
 * @access  Private (Admin only)
 */
const submitDecision = asyncHandler(async (req, res) => {
  const { decision, notes } = req.body;

  const result = await PhotoVerificationService.submitReviewDecision({
    caseId: req.params.caseId,
    decision,
    notes,
    reviewerId: req.user._id
  });

  // Audit log
  await AuditService.log({
    user: req.user,
    action: 'PHOTO_VERIFICATION_REVIEW',
    resourceType: 'AnimalCase',
    resourceId: req.params.caseId,
    details: { decision, notes },
    req
  });

  return ApiResponse.success(res, 'Photo verification decision recorded.', { result });
});

module.exports = {
  getComparison,
  submitDecision
};

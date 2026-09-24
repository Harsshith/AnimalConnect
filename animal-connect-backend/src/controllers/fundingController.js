const FundingRequest = require('../models/FundingRequest');
const AnimalCase = require('../models/AnimalCase');
const Facility = require('../models/Facility');
const ApiResponse = require('../utils/apiResponse');
const AppError = require('../utils/appError');
const asyncHandler = require('../utils/asyncHandler');
const { generateFundingId } = require('../utils/idGenerator');
const NotificationService = require('../services/notificationService');
const AuditService = require('../services/auditService');

/**
 * @desc    Create a funding request for an animal case
 * @route   POST /api/funding-requests
 * @access  Private (Hospital, Clinic or Admin)
 */
const createFundingRequest = asyncHandler(async (req, res) => {
  const {
    caseId,
    facilityId,
    diagnosis,
    treatmentDetails,
    requestedAmount,
    pawcareSupport = 0,
    evidenceDocuments
  } = req.body;

  const animalCase = await AnimalCase.findById(caseId);
  if (!animalCase) {
    throw new AppError('Animal case not found.', 404);
  }

  const facility = await Facility.findById(facilityId);
  if (!facility) {
    throw new AppError('Facility not found.', 404);
  }

  const fundingId = generateFundingId();
  const reqAmount = parseFloat(requestedAmount);
  const pwSupport = parseFloat(pawcareSupport) || 0;
  const remAmount = Math.max(0, reqAmount - pwSupport);

  const fundingRequest = await FundingRequest.create({
    fundingId,
    caseId: animalCase._id,
    facilityId: facility._id,
    animalName: `${animalCase.animalType} Rescue`,
    animalImageUrl: animalCase.imageUrl,
    volunteerName: animalCase.reporterName,
    hospitalName: facility.name,
    diagnosis,
    treatmentDetails,
    requestedAmount: reqAmount,
    pawcareSupport: pwSupport,
    donorSupport: 0,
    remainingAmount: remAmount,
    evidenceDocuments: evidenceDocuments || [],
    checklist: {
      volunteerVerified: true,
      hospitalVerified: facility.isVerified,
      photosMatched: animalCase.photoMatchStatus === 'matched',
      treatmentSubmitted: true,
      medicalEvidenceSubmitted: (evidenceDocuments && evidenceDocuments.length > 0) || false
    },
    status: 'Submitted',
    createdBy: req.user._id,
    approvalHistory: [
      {
        status: 'Submitted',
        changedBy: req.user._id,
        remarks: 'Funding request submitted for review'
      }
    ]
  });

  // Update animal case status
  animalCase.status = 'Funding Review';
  animalCase.estimatedCost = reqAmount;
  animalCase.pawcareSupport = pwSupport;
  animalCase.remainingCost = remAmount;
  await animalCase.save();

  return ApiResponse.success(
    res,
    'Funding request created and submitted for verification.',
    { fundingRequest },
    201
  );
});

/**
 * @desc    Get all funding requests
 * @route   GET /api/funding-requests
 * @access  Public / Authenticated
 */
const getFundingRequests = asyncHandler(async (req, res) => {
  const { status, isApproved, facilityId, page = 1, limit = 20 } = req.query;

  const query = {};
  if (status) query.status = status;
  if (isApproved !== undefined) query.isApproved = isApproved === 'true';
  if (facilityId) query.facilityId = facilityId;

  const pageNum = parseInt(page, 10) || 1;
  const limitNum = parseInt(limit, 10) || 20;
  const skip = (pageNum - 1) * limitNum;

  const total = await FundingRequest.countDocuments(query);
  const requests = await FundingRequest.find(query)
    .populate('caseId')
    .populate('facilityId', 'name phone address city isVerified')
    .sort('-createdAt')
    .skip(skip)
    .limit(limitNum);

  return ApiResponse.paginated(res, 'Funding requests retrieved.', requests, {
    total,
    page: pageNum,
    limit: limitNum,
    totalPages: Math.ceil(total / limitNum)
  });
});

/**
 * @desc    Get funding request by ID
 * @route   GET /api/funding-requests/:id
 * @access  Public / Authenticated
 */
const getFundingRequestById = asyncHandler(async (req, res) => {
  const request = await FundingRequest.findById(req.params.id)
    .populate('caseId')
    .populate('facilityId', 'name phone address city isVerified')
    .populate('createdBy', 'fullName role');

  if (!request) {
    throw new AppError('Funding request not found.', 404);
  }

  return ApiResponse.success(res, 'Funding request details retrieved.', {
    fundingRequest: request
  });
});

/**
 * @desc    Submit draft funding request for review
 * @route   POST /api/funding-requests/:id/submit
 * @access  Private
 */
const submitFundingRequest = asyncHandler(async (req, res) => {
  const request = await FundingRequest.findById(req.params.id);
  if (!request) {
    throw new AppError('Funding request not found.', 404);
  }

  request.status = 'Submitted';
  request.approvalHistory.push({
    status: 'Submitted',
    changedBy: req.user._id,
    remarks: 'Submitted for verification review'
  });
  await request.save();

  return ApiResponse.success(res, 'Funding request submitted for review.', {
    fundingRequest: request
  });
});

/**
 * @desc    Review/Approve/Reject funding request (Admin Only)
 * @route   PUT /api/funding-requests/:id/review
 * @access  Private (Admin Only)
 */
const reviewFundingRequest = asyncHandler(async (req, res) => {
  const { status, approvedAmount, pawcareSupport, remarks, checklist } = req.body;

  // STRICT SECURITY CHECK: A hospital must not approve its own funding request!
  if (req.user.role !== 'admin') {
    throw new AppError(
      'Unauthorized. Funding requests can only be approved by an authorized administrator.',
      403
    );
  }

  const request = await FundingRequest.findById(req.params.id);
  if (!request) {
    throw new AppError('Funding request not found.', 404);
  }

  if (checklist) {
    request.checklist = { ...request.checklist.toObject(), ...checklist };
  }

  const isApprovedStatus = status === 'Approved';
  request.status = status;
  request.isApproved = isApprovedStatus;

  if (approvedAmount !== undefined) {
    request.approvedAmount = parseFloat(approvedAmount);
  }
  if (pawcareSupport !== undefined) {
    request.pawcareSupport = parseFloat(pawcareSupport);
  }

  request.remainingAmount = Math.max(
    0,
    (request.approvedAmount || request.requestedAmount) - request.pawcareSupport - request.donorSupport
  );

  request.approvalHistory.push({
    status: `Review Decision: ${status}`,
    changedBy: req.user._id,
    remarks: remarks || ''
  });

  await request.save();

  // Audit log
  await AuditService.log({
    user: req.user,
    action: `FUNDING_REVIEW_${status.toUpperCase()}`,
    resourceType: 'FundingRequest',
    resourceId: request._id,
    details: { status, approvedAmount, pawcareSupport, remarks },
    req
  });

  // Notify creator
  await NotificationService.send({
    userId: request.createdBy,
    title: `Funding Request ${status}`,
    body: `Funding request for ${request.animalName} has been ${status.toLowerCase()}.`,
    category: 'Funding',
    caseId: request.caseId
  });

  return ApiResponse.success(res, `Funding request ${status.toLowerCase()} successfully.`, {
    fundingRequest: request
  });
});

module.exports = {
  createFundingRequest,
  getFundingRequests,
  getFundingRequestById,
  submitFundingRequest,
  reviewFundingRequest
};

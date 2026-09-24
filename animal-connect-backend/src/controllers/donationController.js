const Donation = require('../models/Donation');
const FundingRequest = require('../models/FundingRequest');
const AnimalCase = require('../models/AnimalCase');
const MockPaymentService = require('../services/mockPaymentService');
const ApiResponse = require('../utils/apiResponse');
const AppError = require('../utils/appError');
const asyncHandler = require('../utils/asyncHandler');
const NotificationService = require('../services/notificationService');

/**
 * @desc    Get eligible cases requiring donation support
 * @route   GET /api/donations/cases
 * @access  Public
 */
const getEligibleCases = asyncHandler(async (req, res) => {
  // Find cases that have remaining cost or approved funding requests
  const cases = await AnimalCase.find({
    remainingCost: { $gt: 0 },
    status: { $in: ['Under Treatment', 'Funding Review', 'Admitted'] }
  })
    .populate('selectedFacility', 'name address city')
    .sort('-priority -createdAt');

  return ApiResponse.success(res, 'Eligible donation cases retrieved.', { cases });
});

/**
 * @desc    Create a donation (case-specific or general welfare)
 * @route   POST /api/donations
 * @access  Public / Authenticated
 */
const createDonation = asyncHandler(async (req, res) => {
  const {
    caseId,
    caseTitle,
    donorName,
    donorEmail,
    donorPhone,
    amount,
    category,
    paymentMethod,
    idempotencyKey
  } = req.body;

  const donationAmount = parseFloat(amount);
  if (!donationAmount || donationAmount <= 0) {
    throw new AppError('Donation amount must be greater than zero.', 400);
  }

  // 1. Process simulated payment via isolated MockPaymentService
  const paymentResult = await MockPaymentService.processPayment({
    amount: donationAmount,
    idempotencyKey,
    paymentMethod: paymentMethod || 'mock_gateway'
  });

  // If idempotent repeat request, return the existing completed donation
  if (paymentResult.isDuplicate) {
    const existing = await Donation.findOne({ transactionId: paymentResult.transactionId });
    return ApiResponse.success(res, 'Donation already processed.', { donation: existing });
  }

  // Determine linked user if logged in
  const userId = req.user ? req.user._id : null;
  const resolvedDonorName = donorName || (req.user ? req.user.fullName : 'Anonymous Supporter');

  let resolvedTitle = caseTitle || 'General Animal Care';
  let linkedCase = null;

  if (caseId) {
    linkedCase = await AnimalCase.findById(caseId);
    if (linkedCase) {
      resolvedTitle = `${linkedCase.animalType} (${linkedCase.condition})`;

      // Update animal case donation amounts
      linkedCase.donorSupport = (linkedCase.donorSupport || 0) + donationAmount;
      linkedCase.remainingCost = Math.max(0, (linkedCase.remainingCost || 0) - donationAmount);
      await linkedCase.save();

      // Update linked funding request if any
      const fundingReq = await FundingRequest.findOne({ caseId: linkedCase._id });
      if (fundingReq) {
        fundingReq.donorSupport = (fundingReq.donorSupport || 0) + donationAmount;
        fundingReq.remainingAmount = Math.max(0, (fundingReq.remainingAmount || 0) - donationAmount);
        if (fundingReq.remainingAmount <= 0) {
          fundingReq.status = 'Fully Funded';
        } else {
          fundingReq.status = 'Partially Funded';
        }
        await fundingReq.save();
      }
    }
  }

  // 2. Save Donation Record
  const donation = await Donation.create({
    transactionId: paymentResult.transactionId,
    caseId: linkedCase ? linkedCase._id : null,
    caseTitle: resolvedTitle,
    donor: userId,
    donorName: resolvedDonorName,
    donorEmail: donorEmail || (req.user ? req.user.email : ''),
    donorPhone: donorPhone || (req.user ? req.user.phone : ''),
    amount: donationAmount,
    category: category || (linkedCase ? 'Emergency Treatment' : 'General Animal Care'),
    paymentStatus: paymentResult.status,
    paymentMethod: paymentResult.paymentMethod,
    idempotencyKey: idempotencyKey || null,
    date: new Date()
  });

  // Notify donor if authenticated
  if (userId) {
    await NotificationService.send({
      userId,
      title: `Donation Successful: ₹${donationAmount}`,
      body: `Thank you for contributing ₹${donationAmount} toward ${resolvedTitle}. Transaction ID: ${donation.transactionId}`,
      category: 'Donation',
      caseId: linkedCase ? linkedCase._id : null
    });
  }

  return ApiResponse.success(
    res,
    'Donation processed successfully. Thank you for your support!',
    { donation },
    201
  );
});

/**
 * @desc    Get current user's donations
 * @route   GET /api/donations/my
 * @access  Private
 */
const getMyDonations = asyncHandler(async (req, res) => {
  const donations = await Donation.find({ donor: req.user._id })
    .populate('caseId', 'caseId animalType condition')
    .sort('-date');

  return ApiResponse.success(res, 'Donation history retrieved.', { donations });
});

/**
 * @desc    Get donation receipt by ID
 * @route   GET /api/donations/:id
 * @access  Public / Authenticated
 */
const getDonationById = asyncHandler(async (req, res) => {
  const donation = await Donation.findById(req.params.id).populate('caseId');
  if (!donation) {
    throw new AppError('Donation record not found.', 404);
  }

  return ApiResponse.success(res, 'Donation receipt retrieved.', { donation });
});

module.exports = {
  getEligibleCases,
  createDonation,
  getMyDonations,
  getDonationById
};

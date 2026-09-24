const crypto = require('crypto');
const AppError = require('../utils/appError');
const Donation = require('../models/Donation');

/**
 * Mock Payment Gateway Service
 * Simulates a payment gateway (e.g. Razorpay/Stripe) without touching real money or storing card data
 */
class MockPaymentService {
  /**
   * Process a simulated donation payment
   * @param {Object} paymentData
   * @param {number} paymentData.amount
   * @param {string} [paymentData.idempotencyKey]
   * @param {string} [paymentData.paymentMethod]
   */
  static async processPayment({ amount, idempotencyKey, paymentMethod = 'mock_gateway' }) {
    if (!amount || amount <= 0) {
      throw new AppError('Payment amount must be greater than zero.', 400);
    }

    // Idempotency check: if key is provided and already succeeded, return existing
    if (idempotencyKey) {
      const existingDonation = await Donation.findOne({ idempotencyKey, paymentStatus: 'completed' });
      if (existingDonation) {
        return {
          isDuplicate: true,
          transactionId: existingDonation.transactionId,
          status: 'completed',
          message: 'Idempotent request: donation already processed.'
        };
      }
    }

    // Generate unique mock transaction ID
    const txnRandom = crypto.randomBytes(4).toString('hex').toUpperCase();
    const transactionId = `TXN-MOCK-${Date.now()}-${txnRandom}`;

    // Return simulated success response
    return {
      isDuplicate: false,
      transactionId,
      status: 'completed',
      paymentMethod,
      gatewayResponse: {
        gateway: 'MockPaymentGateway',
        verified: true,
        authCode: `AUTH-${txnRandom}`,
        simulated: true
      }
    };
  }
}

module.exports = MockPaymentService;

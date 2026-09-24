/**
 * Unique ID generator for cases, orders, donations, and funding requests
 */
const crypto = require('crypto');

const generateId = (prefix = 'ID') => {
  const timestamp = Date.now().toString().slice(-6);
  const random = crypto.randomBytes(3).toString('hex').toUpperCase();
  return `${prefix}-${timestamp}-${random}`;
};

module.exports = {
  generateId,
  generateCaseId: () => generateId('CASE'),
  generateDonationId: () => generateId('DON'),
  generateFundingId: () => generateId('FUND'),
  generateOrderId: () => generateId('ORD'),
  generateApplicationId: () => generateId('APP')
};

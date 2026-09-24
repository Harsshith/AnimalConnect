const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../src/app');
const User = require('../src/models/User');
const Facility = require('../src/models/Facility');
const AnimalCase = require('../src/models/AnimalCase');
const FundingRequest = require('../src/models/FundingRequest');
const env = require('../src/config/env');

let hospitalToken = '';
let adminToken = '';
let caseId = '';
let facilityId = '';
let fundingId = '';

beforeAll(async () => {
  if (mongoose.connection.readyState === 0) {
    await mongoose.connect(env.mongoUri);
  }

  const hospUser = await User.create({
    fullName: 'Fund Hosp User',
    email: `fundhosp_${Date.now()}@example.com`,
    phone: `+9198${Math.floor(10000000 + Math.random() * 90000000)}`,
    password: 'Password@123',
    role: 'hospital',
    isVerified: true
  });

  const hospRes = await request(app)
    .post('/api/auth/login')
    .send({ email: hospUser.email, password: 'Password@123' });
  hospitalToken = hospRes.body.data.token;

  const adminUser = await User.create({
    fullName: 'Fund Admin User',
    email: `fundadmin_${Date.now()}@example.com`,
    phone: `+9198${Math.floor(10000000 + Math.random() * 90000000)}`,
    password: 'Password@123',
    role: 'admin',
    isVerified: true
  });

  const adminRes = await request(app)
    .post('/api/auth/login')
    .send({ email: adminUser.email, password: 'Password@123' });
  adminToken = adminRes.body.data.token;

  const facility = await Facility.create({
    name: 'Fund Test Hospital',
    type: 'hospital',
    owner: hospUser._id,
    phone: '+919876511111',
    address: '100 Medical Way',
    city: 'Coimbatore',
    isVerified: true
  });
  facilityId = facility._id;

  const aCase = await AnimalCase.create({
    caseId: `CASE-${Date.now()}`,
    reporter: hospUser._id,
    reporterName: 'Fund Reporter',
    reporterPhone: '+919876511111',
    animalType: 'Cat',
    condition: 'Sick',
    description: 'Dehydrated kitten needing IV support',
    locationAddress: 'Gandhi Park'
  });
  caseId = aCase._id;
});

afterAll(async () => {
  if (fundingId) await FundingRequest.findByIdAndDelete(fundingId);
  if (caseId) await AnimalCase.findByIdAndDelete(caseId);
  if (facilityId) await Facility.findByIdAndDelete(facilityId);
  await User.deleteMany({ email: /fund.*@example\.com/ });
  await mongoose.connection.close();
});

describe('4. Treatment Funding & Security Tests', () => {
  it('POST /api/funding-requests - Should create a funding request linked to case', async () => {
    const res = await request(app)
      .post('/api/funding-requests')
      .set('Authorization', `Bearer ${hospitalToken}`)
      .send({
        caseId,
        facilityId,
        diagnosis: 'Severe dehydration and gastroenteritis',
        treatmentDetails: 'IV fluids, antibiotic therapy, nursing care',
        requestedAmount: 3000,
        pawcareSupport: 1000
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.fundingRequest.requestedAmount).toBe(3000);
    expect(res.body.data.fundingRequest.remainingAmount).toBe(2000);
    fundingId = res.body.data.fundingRequest._id;
  });

  it('PUT /api/funding-requests/:id/review - Should PREVENT a hospital from approving its own request', async () => {
    const res = await request(app)
      .put(`/api/funding-requests/${fundingId}/review`)
      .set('Authorization', `Bearer ${hospitalToken}`)
      .send({
        status: 'Approved',
        approvedAmount: 3000
      });

    expect(res.status).toBe(403);
    expect(res.body.success).toBe(false);
  });

  it('PUT /api/funding-requests/:id/review - Should allow Administrator to approve funding request', async () => {
    const res = await request(app)
      .put(`/api/funding-requests/${fundingId}/review`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        status: 'Approved',
        approvedAmount: 3000,
        pawcareSupport: 1000,
        remarks: 'Medical case verified and approved.'
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.fundingRequest.status).toBe('Approved');
    expect(res.body.data.fundingRequest.isApproved).toBe(true);
  });

  it('POST /api/donations - Should simulate mock donation and update case remaining cost', async () => {
    const res = await request(app)
      .post('/api/donations')
      .send({
        caseId,
        amount: 500,
        donorName: 'Generous Supporter',
        category: 'Emergency Treatment'
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.donation.paymentStatus).toBe('completed');
    expect(res.body.data.donation.transactionId).toMatch(/^TXN-MOCK-/);
  });
});

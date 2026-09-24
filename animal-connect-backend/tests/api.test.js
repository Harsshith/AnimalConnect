const { describe, it, before, after } = require('node:test');
const assert = require('node:assert');
const request = require('supertest');
const mongoose = require('mongoose');

const app = require('../src/app');
const User = require('../src/models/User');
const Facility = require('../src/models/Facility');
const AnimalCase = require('../src/models/AnimalCase');
const CaseStatusHistory = require('../src/models/CaseStatusHistory');
const FundingRequest = require('../src/models/FundingRequest');
const MedicineOrder = require('../src/models/MedicineOrder');
const env = require('../src/config/env');

before(async () => {
  if (mongoose.connection.readyState === 0) {
    await mongoose.connect(env.mongoUri);
  }
});

after(async () => {
  await User.deleteMany({ email: /.*testrunner.*@example\.com/ });
  await mongoose.connection.close();
});

describe('Animal Connect Comprehensive API Test Suite', () => {
  let volunteerToken = '';
  let hospitalToken = '';
  let adminToken = '';
  let testCaseId = '';
  let testFacilityId = '';
  let testFundingId = '';

  it('Health check endpoint returns operational status', async () => {
    const res = await request(app).get('/api/health');
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.success, true);
    assert.match(res.body.message, /healthy and operational/i);
  });

  it('Auth - Register Volunteer', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send({
        fullName: 'Test Volunteer Runner',
        email: `vol_testrunner_${Date.now()}@example.com`,
        phone: `+9198${Math.floor(10000000 + Math.random() * 90000000)}`,
        password: 'Password@123',
        role: 'volunteer',
        city: 'Coimbatore'
      });

    assert.strictEqual(res.status, 201);
    assert.strictEqual(res.body.success, true);
    assert.ok(res.body.data.token);
    assert.strictEqual(res.body.data.user.password, undefined);
    volunteerToken = res.body.data.token;
  });

  it('Auth - Reject duplicate email registration', async () => {
    const duplicateEmail = `dup_testrunner_${Date.now()}@example.com`;
    await request(app)
      .post('/api/auth/register')
      .send({
        fullName: 'Original User',
        email: duplicateEmail,
        phone: `+9198${Math.floor(10000000 + Math.random() * 90000000)}`,
        password: 'Password@123'
      });

    const res = await request(app)
      .post('/api/auth/register')
      .send({
        fullName: 'Duplicate User',
        email: duplicateEmail,
        phone: `+9198${Math.floor(10000000 + Math.random() * 90000000)}`,
        password: 'Password@123'
      });

    assert.strictEqual(res.status, 400);
    assert.strictEqual(res.body.success, false);
  });

  it('Auth - Register Hospital & Admin', async () => {
    const hospEmail = `hosp_testrunner_${Date.now()}@example.com`;
    const hospRes = await request(app)
      .post('/api/auth/register')
      .send({
        fullName: 'Lead Vet Surgeon',
        email: hospEmail,
        phone: `+9198${Math.floor(10000000 + Math.random() * 90000000)}`,
        password: 'Password@123',
        role: 'hospital',
        city: 'Coimbatore'
      });

    assert.strictEqual(hospRes.status, 201);
    hospitalToken = hospRes.body.data.token;

    // Login as pre-seeded admin
    const adminRes = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'admin@animalconnect.org',
        password: 'Admin@123456'
      });

    assert.strictEqual(adminRes.status, 200);
    adminToken = adminRes.body.data.token;
  });

  it('Cases - Create Animal Case', async () => {
    const res = await request(app)
      .post('/api/cases')
      .set('Authorization', `Bearer ${volunteerToken}`)
      .send({
        animalType: 'Dog',
        condition: 'Injured',
        description: 'Street dog with lacerated front paw found near bridge.',
        locationAddress: 'Mettupalayam Road, Coimbatore',
        priority: 'High'
      });

    assert.strictEqual(res.status, 201);
    assert.strictEqual(res.body.success, true);
    assert.match(res.body.data.case.caseId, /^CASE-/);
    assert.strictEqual(res.body.data.case.status, 'Reported');
    testCaseId = res.body.data.case._id;
  });

  it('Cases - Fetch and filter cases', async () => {
    const res = await request(app).get('/api/cases?limit=5');
    assert.strictEqual(res.status, 200);
    assert.ok(Array.isArray(res.body.data.items));
  });

  it('Cases - Update Case Status and record history', async () => {
    const res = await request(app)
      .put(`/api/cases/${testCaseId}`)
      .set('Authorization', `Bearer ${volunteerToken}`)
      .send({
        status: 'Admitted',
        remarks: 'Admitted for emergency wound cleaning'
      });

    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.data.case.status, 'Admitted');

    const hist = await request(app).get(`/api/cases/${testCaseId}/history`);
    assert.strictEqual(hist.status, 200);
    assert.ok(hist.body.data.history.length >= 2);
  });

  it('Facilities - Register Clinic (starts pending verification)', async () => {
    const res = await request(app)
      .post('/api/facilities/clinics/register')
      .set('Authorization', `Bearer ${hospitalToken}`)
      .send({
        name: 'Test Vet Clinic Runner',
        phone: '+914221199887',
        email: 'runner@vetclinic.com',
        address: '55 Race Course',
        city: 'Coimbatore',
        longitude: 76.9600,
        latitude: 11.0100
      });

    assert.strictEqual(res.status, 201);
    assert.strictEqual(res.body.data.facility.verificationStatus, 'pending');
    assert.strictEqual(res.body.data.facility.isVerified, false);
    testFacilityId = res.body.data.facility._id;
  });

  it('Facilities Security - Prevent facility self-verification', async () => {
    const res = await request(app)
      .put(`/api/facilities/${testFacilityId}`)
      .set('Authorization', `Bearer ${hospitalToken}`)
      .send({ verificationStatus: 'verified' });

    assert.strictEqual(res.status, 403);
    assert.strictEqual(res.body.success, false);
  });

  it('Facilities Admin - Admin verifies facility', async () => {
    const res = await request(app)
      .put(`/api/admin/facilities/${testFacilityId}/verify`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ status: 'verified', remarks: 'Official license verified' });

    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.data.facility.verificationStatus, 'verified');
    assert.strictEqual(res.body.data.facility.isVerified, true);
  });

  it('Facilities - Nearby geospatial query returns facilities', async () => {
    const res = await request(app).get('/api/facilities/nearby?latitude=11.0100&longitude=76.9600&radius=10');
    assert.strictEqual(res.status, 200);
    assert.ok(Array.isArray(res.body.data.facilities));
  });

  it('Funding - Hospital creates funding request', async () => {
    const res = await request(app)
      .post('/api/funding-requests')
      .set('Authorization', `Bearer ${hospitalToken}`)
      .send({
        caseId: testCaseId,
        facilityId: testFacilityId,
        diagnosis: 'Lacerated paw with tendon exposure',
        treatmentDetails: 'Surgical suturing, local nerve block, antibiotic therapy',
        requestedAmount: 4000,
        pawcareSupport: 1500
      });

    assert.strictEqual(res.status, 201);
    assert.strictEqual(res.body.data.fundingRequest.requestedAmount, 4000);
    assert.strictEqual(res.body.data.fundingRequest.remainingAmount, 2500);
    testFundingId = res.body.data.fundingRequest._id;
  });

  it('Funding Security - Prevent hospital self-approval of funding', async () => {
    const res = await request(app)
      .put(`/api/funding-requests/${testFundingId}/review`)
      .set('Authorization', `Bearer ${hospitalToken}`)
      .send({ status: 'Approved' });

    assert.strictEqual(res.status, 403);
    assert.strictEqual(res.body.success, false);
  });

  it('Funding Admin - Admin approves verified funding request', async () => {
    const res = await request(app)
      .put(`/api/funding-requests/${testFundingId}/review`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        status: 'Approved',
        approvedAmount: 4000,
        pawcareSupport: 1500,
        remarks: 'Reviewed and approved'
      });

    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.data.fundingRequest.status, 'Approved');
    assert.strictEqual(res.body.data.fundingRequest.isApproved, true);
  });

  it('Donations - Mock payment processes donation and updates remaining funds', async () => {
    const res = await request(app)
      .post('/api/donations')
      .send({
        caseId: testCaseId,
        amount: 1000,
        donorName: 'Test Benefactor',
        category: 'Emergency Treatment'
      });

    assert.strictEqual(res.status, 201);
    assert.strictEqual(res.body.data.donation.paymentStatus, 'completed');
    assert.match(res.body.data.donation.transactionId, /^TXN-MOCK-/);

    // Verify case donorSupport incremented
    const updatedCase = await AnimalCase.findById(testCaseId);
    assert.strictEqual(updatedCase.donorSupport, 1000);
  });

  it('Medicine - Catalog retrieval', async () => {
    const res = await request(app).get('/api/medicines');
    assert.strictEqual(res.status, 200);
    assert.ok(Array.isArray(res.body.data.medicines));
  });

  it('Medicine - Order without prescription for Rx medicine is rejected', async () => {
    const res = await request(app)
      .post('/api/medicine-orders')
      .set('Authorization', `Bearer ${volunteerToken}`)
      .send({
        deliveryAddress: '10 Main Road, Coimbatore',
        items: [
          {
            name: 'Restricted Antibiotic Injection',
            price: 350,
            quantity: 1,
            isPrescriptionRequired: true
          }
        ]
      });

    assert.strictEqual(res.status, 400);
    assert.strictEqual(res.body.success, false);
  });

  it('Medicine - Order with prescription is accepted', async () => {
    const res = await request(app)
      .post('/api/medicine-orders')
      .set('Authorization', `Bearer ${volunteerToken}`)
      .send({
        deliveryAddress: '10 Main Road, Coimbatore',
        prescriptionUrl: 'https://example.com/rx/verified-vet-rx.pdf',
        items: [
          {
            name: 'Restricted Antibiotic Injection',
            price: 350,
            quantity: 1,
            isPrescriptionRequired: true
          }
        ]
      });

    assert.strictEqual(res.status, 201);
    assert.strictEqual(res.body.data.order.status, 'prescriptionSubmitted');
  });

  it('Adoption - Public browse available animals', async () => {
    const res = await request(app).get('/api/adoption/animals');
    assert.strictEqual(res.status, 200);
    assert.ok(Array.isArray(res.body.data.animals));
  });

  it('Notifications - Retrieve user notifications', async () => {
    const res = await request(app)
      .get('/api/notifications')
      .set('Authorization', `Bearer ${volunteerToken}`);

    assert.strictEqual(res.status, 200);
    assert.ok(Array.isArray(res.body.data.notifications));
  });

  it('Admin - View platform statistics', async () => {
    const res = await request(app)
      .get('/api/admin/stats')
      .set('Authorization', `Bearer ${adminToken}`);

    assert.strictEqual(res.status, 200);
    assert.ok(res.body.data.stats.totalCases > 0);
    assert.ok(res.body.data.stats.totalFacilities > 0);
  });
});

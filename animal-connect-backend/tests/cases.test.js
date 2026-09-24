const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../src/app');
const User = require('../src/models/User');
const AnimalCase = require('../src/models/AnimalCase');
const CaseStatusHistory = require('../src/models/CaseStatusHistory');
const env = require('../src/config/env');

let authToken = '';
let userId = '';
let testCaseId = '';

beforeAll(async () => {
  if (mongoose.connection.readyState === 0) {
    await mongoose.connect(env.mongoUri);
  }

  // Create a clean volunteer user
  const email = `case_test_${Date.now()}@example.com`;
  const user = await User.create({
    fullName: 'Case Tester',
    email,
    phone: `+9198${Math.floor(10000000 + Math.random() * 90000000)}`,
    password: 'Password@123',
    role: 'volunteer',
    isVerified: true
  });
  userId = user._id;

  const loginRes = await request(app)
    .post('/api/auth/login')
    .send({ email, password: 'Password@123' });

  authToken = loginRes.body.data.token;
});

afterAll(async () => {
  if (testCaseId) {
    await AnimalCase.findByIdAndDelete(testCaseId);
    await CaseStatusHistory.deleteMany({ caseId: testCaseId });
  }
  if (userId) {
    await User.findByIdAndDelete(userId);
  }
  await mongoose.connection.close();
});

describe('2. Animal Case Module Tests', () => {
  it('POST /api/cases - Should create a new animal case with unique Case ID', async () => {
    const res = await request(app)
      .post('/api/cases')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        animalType: 'Dog',
        condition: 'Injured',
        description: 'Street dog with paw laceration requiring medical dressing.',
        locationAddress: 'Trichy Road, Coimbatore',
        priority: 'Medium'
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.case.caseId).toMatch(/^CASE-/);
    expect(res.body.data.case.status).toBe('Reported');
    testCaseId = res.body.data.case._id;
  });

  it('GET /api/cases - Should return list of cases with pagination', async () => {
    const res = await request(app).get('/api/cases?limit=10');
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data.items)).toBe(true);
  });

  it('GET /api/cases/:id - Should fetch single case details with status history', async () => {
    const res = await request(app).get(`/api/cases/${testCaseId}`);
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.case._id).toBe(testCaseId);
    expect(Array.isArray(res.body.data.history)).toBe(true);
  });

  it('PUT /api/cases/:id - Should update case status and record transition history', async () => {
    const res = await request(app)
      .put(`/api/cases/${testCaseId}`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        status: 'Admitted',
        remarks: 'Transferred to veterinary clinic'
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.case.status).toBe('Admitted');

    // Verify history record
    const historyRes = await request(app).get(`/api/cases/${testCaseId}/history`);
    expect(historyRes.status).toBe(200);
    expect(historyRes.body.data.history.length).toBeGreaterThanOrEqual(2);
  });
});

const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../src/app');
const User = require('../src/models/User');
const Facility = require('../src/models/Facility');
const env = require('../src/config/env');

let hospitalToken = '';
let adminToken = '';
let facilityId = '';

beforeAll(async () => {
  if (mongoose.connection.readyState === 0) {
    await mongoose.connect(env.mongoUri);
  }

  // Create hospital user
  const hospUser = await User.create({
    fullName: 'Test Clinic Lead',
    email: `clinic_${Date.now()}@example.com`,
    phone: `+9198${Math.floor(10000000 + Math.random() * 90000000)}`,
    password: 'Password@123',
    role: 'clinic',
    isVerified: true
  });

  const hospRes = await request(app)
    .post('/api/auth/login')
    .send({ email: hospUser.email, password: 'Password@123' });
  hospitalToken = hospRes.body.data.token;

  // Create admin user
  const adminUser = await User.create({
    fullName: 'Test Admin Lead',
    email: `admin_${Date.now()}@example.com`,
    phone: `+9198${Math.floor(10000000 + Math.random() * 90000000)}`,
    password: 'Password@123',
    role: 'admin',
    isVerified: true
  });

  const adminRes = await request(app)
    .post('/api/auth/login')
    .send({ email: adminUser.email, password: 'Password@123' });
  adminToken = adminRes.body.data.token;
});

afterAll(async () => {
  if (facilityId) {
    await Facility.findByIdAndDelete(facilityId);
  }
  await User.deleteMany({ email: /.*_.*@example\.com/ });
  await mongoose.connection.close();
});

describe('3. Facility & Geospatial Search Tests', () => {
  it('POST /api/facilities/clinics/register - Should register facility with pending verification status', async () => {
    const res = await request(app)
      .post('/api/facilities/clinics/register')
      .set('Authorization', `Bearer ${hospitalToken}`)
      .send({
        name: 'Alpha Vet Care Clinic',
        phone: '+914221122334',
        email: 'alpha@vetcare.com',
        address: '100 Sunset Boulevard',
        city: 'Coimbatore',
        longitude: 76.9600,
        latitude: 11.0100
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.facility.verificationStatus).toBe('pending');
    expect(res.body.data.facility.isVerified).toBe(false);
    facilityId = res.body.data.facility._id;
  });

  it('PUT /api/facilities/:id - Should PREVENT a facility from approving its own verification', async () => {
    const res = await request(app)
      .put(`/api/facilities/${facilityId}`)
      .set('Authorization', `Bearer ${hospitalToken}`)
      .send({
        verificationStatus: 'verified'
      });

    expect(res.status).toBe(403);
    expect(res.body.success).toBe(false);
  });

  it('PUT /api/admin/facilities/:id/verify - Should allow Admin to verify the facility', async () => {
    const res = await request(app)
      .put(`/api/admin/facilities/${facilityId}/verify`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        status: 'verified',
        remarks: 'Documents verified and validated.'
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.facility.verificationStatus).toBe('verified');
    expect(res.body.data.facility.isVerified).toBe(true);
  });

  it('GET /api/facilities/nearby - Should return nearby facilities using geo coordinates', async () => {
    const res = await request(app).get('/api/facilities/nearby?latitude=11.0100&longitude=76.9600&radius=10');
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data.facilities)).toBe(true);
  });
});

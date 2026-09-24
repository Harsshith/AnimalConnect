const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../src/app');
const User = require('../src/models/User');
const env = require('../src/config/env');

beforeAll(async () => {
  if (mongoose.connection.readyState === 0) {
    await mongoose.connect(env.mongoUri);
  }
});

afterAll(async () => {
  await User.deleteMany({ email: /test.*@example\.com/ });
  await mongoose.connection.close();
});

describe('1. Authentication Module Tests', () => {
  const testUser = {
    fullName: 'Test Volunteer',
    email: `test_vol_${Date.now()}@example.com`,
    phone: `+9199999${Math.floor(10000 + Math.random() * 90000)}`,
    password: 'Password@123',
    role: 'volunteer'
  };

  let authToken = '';

  it('POST /api/auth/register - Should register a new volunteer successfully', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send(testUser);

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.email).toBe(testUser.email.toLowerCase());
    expect(res.body.data.token).toBeDefined();
    // Password must never be returned
    expect(res.body.data.user.password).toBeUndefined();
    authToken = res.body.data.token;
  });

  it('POST /api/auth/register - Should fail on duplicate email', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send(testUser);

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
  });

  it('POST /api/auth/login - Should authenticate valid credentials and return JWT', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({
        email: testUser.email,
        password: testUser.password
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.token).toBeDefined();
  });

  it('POST /api/auth/login - Should reject invalid password with 401', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({
        email: testUser.email,
        password: 'WrongPassword'
      });

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
  });

  it('GET /api/auth/me - Should fetch logged-in user profile with valid Bearer token', async () => {
    const res = await request(app)
      .get('/api/auth/me')
      .set('Authorization', `Bearer ${authToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.email).toBe(testUser.email.toLowerCase());
  });

  it('GET /api/auth/me - Should return 401 without Bearer token', async () => {
    const res = await request(app).get('/api/auth/me');
    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
  });
});

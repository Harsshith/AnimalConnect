const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../src/app');
const User = require('../src/models/User');
const MedicineOrder = require('../src/models/MedicineOrder');
const env = require('../src/config/env');

let userToken = '';
let orderId = '';

beforeAll(async () => {
  if (mongoose.connection.readyState === 0) {
    await mongoose.connect(env.mongoUri);
  }

  const user = await User.create({
    fullName: 'Med Tester',
    email: `medtester_${Date.now()}@example.com`,
    phone: `+9198${Math.floor(10000000 + Math.random() * 90000000)}`,
    password: 'Password@123',
    role: 'volunteer',
    isVerified: true
  });

  const loginRes = await request(app)
    .post('/api/auth/login')
    .send({ email: user.email, password: 'Password@123' });
  userToken = loginRes.body.data.token;
});

afterAll(async () => {
  if (orderId) {
    await MedicineOrder.findByIdAndDelete(orderId);
  }
  await User.deleteMany({ email: /medtester.*@example\.com/ });
  await mongoose.connection.close();
});

describe('5. Medicine Delivery & Prescription Validation Tests', () => {
  it('GET /api/medicines - Should retrieve medicine catalog', async () => {
    const res = await request(app).get('/api/medicines');
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data.medicines)).toBe(true);
  });

  it('POST /api/medicine-orders - Should REJECT order with prescription-required medicine if prescription is missing', async () => {
    const res = await request(app)
      .post('/api/medicine-orders')
      .set('Authorization', `Bearer ${userToken}`)
      .send({
        deliveryAddress: '12 Green Avenue, Coimbatore',
        items: [
          {
            name: 'Controlled Antibiotic Solution',
            category: 'Antibiotics',
            price: 250,
            quantity: 1,
            isPrescriptionRequired: true
          }
        ]
      });

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.message).toMatch(/prescription/i);
  });

  it('POST /api/medicine-orders - Should ALLOW order for prescription-required medicine when prescriptionUrl is provided', async () => {
    const res = await request(app)
      .post('/api/medicine-orders')
      .set('Authorization', `Bearer ${userToken}`)
      .send({
        deliveryAddress: '12 Green Avenue, Coimbatore',
        prescriptionUrl: 'https://example.com/prescriptions/vet-signed-rx.pdf',
        items: [
          {
            name: 'Controlled Antibiotic Solution',
            category: 'Antibiotics',
            price: 250,
            quantity: 1,
            isPrescriptionRequired: true
          }
        ]
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.order.status).toBe('prescriptionSubmitted');
    expect(res.body.data.order.orderId).toMatch(/^ORD-/);
    orderId = res.body.data.order._id;
  });
});

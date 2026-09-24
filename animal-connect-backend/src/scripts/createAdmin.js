const mongoose = require('mongoose');
const User = require('../models/User');
const connectDB = require('../config/db');
const env = require('../config/env');

const createAdmin = async () => {
  try {
    await connectDB();

    const { email, password, name, phone } = env.initialAdmin;

    const existing = await User.findOne({ email });
    if (existing) {
      console.log(`[Admin Seeder] Admin user already exists with email: ${email}`);
      process.exit(0);
    }

    const admin = await User.create({
      fullName: name,
      email,
      phone,
      password,
      role: 'admin',
      isVerified: true,
      isActive: true
    });

    console.log(`[Admin Seeder] Successfully created initial Administrator:`);
    console.log(`  Name:  ${admin.fullName}`);
    console.log(`  Email: ${admin.email}`);
    console.log(`  Role:  ${admin.role}`);
    console.log(`  Note:  Remember to update INITIAL_ADMIN_PASSWORD in .env for production.`);

    process.exit(0);
  } catch (err) {
    console.error(`[Admin Seeder Error]`, err.message);
    process.exit(1);
  }
};

createAdmin();

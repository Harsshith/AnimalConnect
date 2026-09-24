const mongoose = require('mongoose');

const donationSchema = new mongoose.Schema(
  {
    transactionId: {
      type: String,
      required: true,
      unique: true,
      index: true
    },
    caseId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'AnimalCase',
      default: null,
      index: true
    },
    caseTitle: {
      type: String,
      default: 'General Animal Welfare'
    },
    donor: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null
    },
    donorName: {
      type: String,
      required: [true, 'Donor name is required'],
      trim: true
    },
    donorEmail: {
      type: String,
      trim: true,
      lowercase: true
    },
    donorPhone: {
      type: String,
      trim: true
    },
    amount: {
      type: Number,
      required: [true, 'Donation amount is required'],
      min: [1, 'Donation must be at least 1']
    },
    category: {
      type: String,
      enum: ['Emergency Treatment', 'Shelter Care', 'Medicine Support', 'General Animal Care'],
      default: 'General Animal Care'
    },
    paymentStatus: {
      type: String,
      enum: ['pending', 'completed', 'failed', 'refunded'],
      default: 'completed'
    },
    paymentMethod: {
      type: String,
      default: 'mock_gateway'
    },
    idempotencyKey: {
      type: String,
      sparse: true,
      index: true
    },
    date: {
      type: Date,
      default: Date.now
    }
  },
  {
    timestamps: true
  }
);

const Donation = mongoose.model('Donation', donationSchema);
module.exports = Donation;

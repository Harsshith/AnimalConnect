const mongoose = require('mongoose');

const volunteerProfileSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true
    },
    capabilities: [
      {
        type: String,
        enum: [
          'Transport animals',
          'Provide temporary care',
          'Help with medicine pickup',
          'Support adoption',
          'Donate'
        ]
      }
    ],
    isAvailable: {
      type: Boolean,
      default: true
    },
    serviceArea: {
      type: String,
      trim: true,
      default: ''
    },
    city: {
      type: String,
      trim: true,
      default: ''
    },
    activityHistory: [
      {
        action: { type: String, required: true },
        caseId: { type: mongoose.Schema.Types.ObjectId, ref: 'AnimalCase' },
        timestamp: { type: Date, default: Date.now },
        notes: { type: String, default: '' }
      }
    ]
  },
  {
    timestamps: true
  }
);

const VolunteerProfile = mongoose.model('VolunteerProfile', volunteerProfileSchema);
module.exports = VolunteerProfile;

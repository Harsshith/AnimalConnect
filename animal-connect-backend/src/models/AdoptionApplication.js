const mongoose = require('mongoose');

const adoptionApplicationSchema = new mongoose.Schema(
  {
    applicationId: {
      type: String,
      required: true,
      unique: true,
      index: true
    },
    animalId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'AdoptionAnimal',
      required: true
    },
    animalName: {
      type: String,
      required: true
    },
    applicant: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    applicantName: {
      type: String,
      required: [true, 'Applicant name is required'],
      trim: true
    },
    applicantPhone: {
      type: String,
      required: [true, 'Applicant phone is required'],
      trim: true
    },
    applicantEmail: {
      type: String,
      trim: true
    },
    livingSituation: {
      type: String,
      required: [true, 'Living situation description is required'],
      trim: true
    },
    petExperience: {
      type: String,
      required: [true, 'Pet experience description is required'],
      trim: true
    },
    reason: {
      type: String,
      required: [true, 'Reason for adoption is required'],
      trim: true
    },
    status: {
      type: String,
      enum: ['Submitted', 'Under Review', 'Approved', 'Rejected'],
      default: 'Submitted',
      index: true
    },
    reviewNotes: {
      type: String,
      default: ''
    },
    reviewedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    reviewedAt: {
      type: Date
    },
    submittedAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    timestamps: true
  }
);

const AdoptionApplication = mongoose.model('AdoptionApplication', adoptionApplicationSchema);
module.exports = AdoptionApplication;

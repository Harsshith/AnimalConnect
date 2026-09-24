const mongoose = require('mongoose');

const prescriptionSchema = new mongoose.Schema(
  {
    caseId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'AnimalCase',
      default: null
    },
    uploadedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    veterinarianName: {
      type: String,
      trim: true,
      default: ''
    },
    clinicName: {
      type: String,
      trim: true,
      default: ''
    },
    prescriptionUrl: {
      type: String,
      required: [true, 'Prescription image/document is required']
    },
    isVerified: {
      type: Boolean,
      default: false
    },
    verifiedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    verifiedAt: {
      type: Date
    },
    notes: {
      type: String,
      default: ''
    }
  },
  {
    timestamps: true
  }
);

const Prescription = mongoose.model('Prescription', prescriptionSchema);
module.exports = Prescription;

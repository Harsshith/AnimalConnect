const mongoose = require('mongoose');

const treatmentRecordSchema = new mongoose.Schema(
  {
    caseId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'AnimalCase',
      required: true,
      index: true
    },
    facilityId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Facility',
      required: true,
      index: true
    },
    veterinarianName: {
      type: String,
      required: [true, 'Veterinarian name is required'],
      trim: true
    },
    licenseNumber: {
      type: String,
      trim: true,
      default: ''
    },
    diagnosis: {
      type: String,
      required: [true, 'Diagnosis is required'],
      trim: true
    },
    treatmentPlan: {
      type: String,
      required: [true, 'Treatment plan is required'],
      trim: true
    },
    medicalNotes: [
      {
        type: String,
        trim: true
      }
    ],
    prescribedMedicines: [
      {
        name: { type: String, required: true },
        dosage: { type: String, required: true },
        frequency: { type: String, default: 'Twice daily' },
        duration: { type: String, default: '5 days' }
      }
    ],
    estimatedCost: {
      type: Number,
      required: [true, 'Estimated cost is required'],
      default: 0
    },
    actualCost: {
      type: Number,
      default: 0
    },
    treatmentStatus: {
      type: String,
      enum: ['in_progress', 'completed', 'transferred', 'referred'],
      default: 'in_progress'
    },
    medicalDocuments: [
      {
        title: { type: String, default: 'Medical Report' },
        url: { type: String, required: true },
        uploadedAt: { type: Date, default: Date.now }
      }
    ],
    treatmentPhotos: [
      {
        url: { type: String, required: true },
        caption: { type: String, default: '' },
        uploadedAt: { type: Date, default: Date.now }
      }
    ],
    recordedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    }
  },
  {
    timestamps: true
  }
);

const TreatmentRecord = mongoose.model('TreatmentRecord', treatmentRecordSchema);
module.exports = TreatmentRecord;

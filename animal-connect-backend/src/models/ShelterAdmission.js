const mongoose = require('mongoose');

const shelterAdmissionSchema = new mongoose.Schema(
  {
    shelterId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Facility',
      required: true,
      index: true
    },
    caseId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'AnimalCase',
      required: true,
      index: true
    },
    requestedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    animalName: {
      type: String,
      default: 'Rescue Animal'
    },
    status: {
      type: String,
      enum: ['pending', 'approved', 'rejected', 'discharged'],
      default: 'pending'
    },
    admissionDate: {
      type: Date
    },
    dischargeDate: {
      type: Date
    },
    assignedKennelOrArea: {
      type: String,
      default: ''
    },
    careNotes: [
      {
        note: { type: String, required: true },
        author: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
        timestamp: { type: Date, default: Date.now }
      }
    ],
    remarks: {
      type: String,
      default: ''
    }
  },
  {
    timestamps: true
  }
);

const ShelterAdmission = mongoose.model('ShelterAdmission', shelterAdmissionSchema);
module.exports = ShelterAdmission;

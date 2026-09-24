const mongoose = require('mongoose');

const fundingRequestSchema = new mongoose.Schema(
  {
    fundingId: {
      type: String,
      required: true,
      unique: true,
      index: true
    },
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
    animalName: {
      type: String,
      default: 'Rescue Animal'
    },
    animalImageUrl: {
      type: String,
      default: ''
    },
    volunteerName: {
      type: String,
      default: ''
    },
    hospitalName: {
      type: String,
      default: ''
    },
    diagnosis: {
      type: String,
      required: true
    },
    treatmentDetails: {
      type: String,
      required: true
    },
    requestedAmount: {
      type: Number,
      required: true,
      min: [0, 'Requested amount must be non-negative']
    },
    approvedAmount: {
      type: Number,
      default: 0
    },
    pawcareSupport: {
      type: Number,
      default: 0
    },
    donorSupport: {
      type: Number,
      default: 0
    },
    remainingAmount: {
      type: Number,
      default: 0
    },
    evidenceDocuments: [
      {
        title: { type: String, default: 'Medical Bill / Evidence' },
        url: { type: String, required: true },
        uploadedAt: { type: Date, default: Date.now }
      }
    ],
    checklist: {
      volunteerVerified: { type: Boolean, default: false },
      hospitalVerified: { type: Boolean, default: false },
      photosMatched: { type: Boolean, default: false },
      treatmentSubmitted: { type: Boolean, default: false },
      medicalEvidenceSubmitted: { type: Boolean, default: false }
    },
    status: {
      type: String,
      enum: [
        'Draft',
        'Submitted',
        'Under Review',
        'Approved',
        'Partially Funded',
        'Fully Funded',
        'Rejected',
        'Paid',
        'Closed'
      ],
      default: 'Draft',
      index: true
    },
    isApproved: {
      type: Boolean,
      default: false
    },
    paymentStatus: {
      type: String,
      enum: ['pending', 'processing', 'disbursed'],
      default: 'pending'
    },
    approvalHistory: [
      {
        status: { type: String, required: true },
        changedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
        remarks: { type: String, default: '' },
        timestamp: { type: Date, default: Date.now }
      }
    ],
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    }
  },
  {
    timestamps: true
  }
);

// Virtual for isFullyVerified
fundingRequestSchema.virtual('isFullyVerified').get(function () {
  return (
    this.checklist.volunteerVerified &&
    this.checklist.hospitalVerified &&
    this.checklist.photosMatched &&
    this.checklist.treatmentSubmitted &&
    this.checklist.medicalEvidenceSubmitted
  );
});

const FundingRequest = mongoose.model('FundingRequest', fundingRequestSchema);
module.exports = FundingRequest;

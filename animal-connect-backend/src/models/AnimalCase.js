const mongoose = require('mongoose');

const animalCaseSchema = new mongoose.Schema(
  {
    caseId: {
      type: String,
      required: true,
      unique: true,
      index: true
    },
    reporter: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    reporterName: {
      type: String,
      required: true
    },
    reporterPhone: {
      type: String,
      required: true
    },
    animalType: {
      type: String,
      required: [true, 'Animal type is required (e.g. Dog, Cat, Other)'],
      trim: true
    },
    condition: {
      type: String,
      enum: ['Critical', 'Injured', 'Sick', 'Healthy', 'Abandoned', 'Puppy/Kitten'],
      required: true
    },
    description: {
      type: String,
      required: [true, 'Case description is required'],
      trim: true
    },
    ageGroup: {
      type: String,
      enum: ['Young', 'Adult', 'Senior', 'Unknown'],
      default: 'Unknown'
    },
    gender: {
      type: String,
      enum: ['Male', 'Female', 'Unknown'],
      default: 'Unknown'
    },
    locationAddress: {
      type: String,
      required: [true, 'Location address is required'],
      trim: true
    },
    landmark: {
      type: String,
      trim: true,
      default: ''
    },
    location: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point'
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        default: [76.9558, 11.0168]
      }
    },
    images: [
      {
        url: { type: String, required: true },
        publicId: { type: String },
        caption: { type: String, default: '' },
        uploadedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
        uploadedRole: { type: String, default: 'volunteer' },
        createdAt: { type: Date, default: Date.now }
      }
    ],
    volunteerAction: {
      type: String,
      default: 'Need Help'
    },
    selectedFacility: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Facility'
    },
    selectedFacilityName: {
      type: String,
      default: ''
    },
    status: {
      type: String,
      enum: [
        'Reported',
        'Facility Selected',
        'Admitted',
        'Under Treatment',
        'Funding Review',
        'Treatment Completed',
        'Shelter Care',
        'Ready for Adoption',
        'Adopted',
        'Closed'
      ],
      default: 'Reported',
      index: true
    },
    priority: {
      type: String,
      enum: ['Low', 'Medium', 'High', 'Critical'],
      default: 'Medium'
    },
    estimatedCost: {
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
    remainingCost: {
      type: Number,
      default: 0
    },
    medicalNotes: [
      {
        type: String
      }
    ],
    photoMatchStatus: {
      type: String,
      enum: ['pending', 'matched', 'mismatch', 'manual_review'],
      default: 'pending'
    },
    photoMatchNotes: {
      type: String,
      default: ''
    }
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
  }
);

// Indexes
animalCaseSchema.index({ location: '2dsphere' });
animalCaseSchema.index({ status: 1, condition: 1, priority: 1 });

// Helper virtual for image URL to match Flutter single imageUrl field
animalCaseSchema.virtual('imageUrl').get(function () {
  if (this.images && this.images.length > 0) {
    return this.images[0].url;
  }
  return 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=600';
});

const AnimalCase = mongoose.model('AnimalCase', animalCaseSchema);
module.exports = AnimalCase;

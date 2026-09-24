const mongoose = require('mongoose');

const facilitySchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Facility name is required'],
      trim: true
    },
    type: {
      type: String,
      enum: ['hospital', 'clinic', 'shelter', 'petCare', 'medicineProvider'],
      required: [true, 'Facility type is required']
    },
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    email: {
      type: String,
      trim: true,
      lowercase: true
    },
    phone: {
      type: String,
      required: [true, 'Contact phone is required'],
      trim: true
    },
    address: {
      type: String,
      required: [true, 'Address is required'],
      trim: true
    },
    city: {
      type: String,
      required: [true, 'City is required'],
      trim: true
    },
    location: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point'
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        required: true,
        default: [76.9558, 11.0168] // Default coords (e.g. Coimbatore center)
      }
    },
    isVerified: {
      type: Boolean,
      default: false
    },
    verificationStatus: {
      type: String,
      enum: ['pending', 'verified', 'rejected', 'suspended'],
      default: 'pending'
    },
    verificationRemarks: {
      type: String,
      default: ''
    },
    verifiedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    verifiedAt: {
      type: Date
    },
    imageUrl: {
      type: String,
      default: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=600'
    },
    rating: {
      type: Number,
      default: 4.8,
      min: 0,
      max: 5
    },
    openHours: {
      type: String,
      default: '24 Hours Emergency'
    },
    isOpenNow: {
      type: Boolean,
      default: true
    },
    hasEmergency: {
      type: Boolean,
      default: true
    },
    offersSupportedCare: {
      type: Boolean,
      default: true
    },
    services: [
      {
        type: String
      }
    ],
    totalAnimalsHelped: {
      type: Number,
      default: 0
    },
    capacity: {
      type: Number,
      default: 0
    },
    currentOccupancy: {
      type: Number,
      default: 0
    },
    registrationDocuments: [
      {
        title: { type: String, default: 'Registration Certificate' },
        url: { type: String, required: true },
        uploadedAt: { type: Date, default: Date.now }
      }
    ]
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
  }
);

// Geospatial index for nearby queries
facilitySchema.index({ location: '2dsphere' });
facilitySchema.index({ type: 1, isVerified: 1 });

// Virtual for available capacity
facilitySchema.virtual('availableCapacity').get(function () {
  if (this.type === 'shelter') {
    return Math.max(0, this.capacity - this.currentOccupancy);
  }
  return 0;
});

const Facility = mongoose.model('Facility', facilitySchema);
module.exports = Facility;

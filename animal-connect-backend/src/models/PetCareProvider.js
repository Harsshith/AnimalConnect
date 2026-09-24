const mongoose = require('mongoose');

const petCareProviderSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    name: {
      type: String,
      required: [true, 'Provider name is required'],
      trim: true
    },
    serviceType: {
      type: String,
      enum: ['Boarding', 'Grooming', 'Foster Care', 'Pet Walking'],
      required: true
    },
    rating: {
      type: Number,
      default: 4.9,
      min: 0,
      max: 5
    },
    pricePerDay: {
      type: Number,
      required: true,
      default: 400
    },
    location: {
      type: String,
      required: true,
      trim: true
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      default: [76.9558, 11.0168]
    },
    isVerified: {
      type: Boolean,
      default: false
    },
    verificationStatus: {
      type: String,
      enum: ['pending', 'verified', 'rejected'],
      default: 'pending'
    },
    availabilityStatus: {
      type: String,
      enum: ['Available', 'Fully Booked'],
      default: 'Available'
    },
    imageUrl: {
      type: String,
      default: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=600'
    },
    description: {
      type: String,
      default: ''
    },
    phone: {
      type: String,
      required: true
    },
    bookings: [
      {
        bookingId: { type: String, required: true },
        user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
        animalType: { type: String, required: true },
        service: { type: String, required: true },
        startDate: { type: Date, required: true },
        endDate: { type: Date, required: true },
        totalAmount: { type: Number, default: 0 },
        status: {
          type: String,
          enum: ['pending', 'confirmed', 'completed', 'cancelled'],
          default: 'pending'
        },
        createdAt: { type: Date, default: Date.now }
      }
    ]
  },
  {
    timestamps: true
  }
);

const PetCareProvider = mongoose.model('PetCareProvider', petCareProviderSchema);
module.exports = PetCareProvider;

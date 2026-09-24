const mongoose = require('mongoose');

const medicineItemSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Medicine name is required'],
      trim: true
    },
    category: {
      type: String,
      enum: ['Wound Care', 'Antibiotics', 'Supplements', 'First Aid', 'Prescription'],
      required: true
    },
    price: {
      type: Number,
      required: [true, 'Price is required'],
      min: [0, 'Price must be positive']
    },
    isPrescriptionRequired: {
      type: Boolean,
      default: false
    },
    providerName: {
      type: String,
      required: true,
      trim: true
    },
    provider: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Facility'
    },
    description: {
      type: String,
      default: ''
    },
    imageUrl: {
      type: String,
      default: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600'
    },
    inStock: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

const MedicineItem = mongoose.model('MedicineItem', medicineItemSchema);
module.exports = MedicineItem;

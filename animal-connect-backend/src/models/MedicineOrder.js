const mongoose = require('mongoose');

const medicineOrderSchema = new mongoose.Schema(
  {
    orderId: {
      type: String,
      required: true,
      unique: true,
      index: true
    },
    caseId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'AnimalCase',
      default: null
    },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    items: [
      {
        medicineId: { type: mongoose.Schema.Types.ObjectId, ref: 'MedicineItem' },
        name: { type: String, required: true },
        category: { type: String },
        price: { type: Number, required: true },
        quantity: { type: Number, required: true, default: 1 },
        isPrescriptionRequired: { type: Boolean, default: false }
      }
    ],
    deliveryAddress: {
      type: String,
      required: [true, 'Delivery address is required'],
      trim: true
    },
    prescriptionUrl: {
      type: String,
      default: ''
    },
    status: {
      type: String,
      enum: [
        'prescriptionSubmitted',
        'verified',
        'preparing',
        'outForDelivery',
        'delivered',
        'cancelled'
      ],
      default: 'prescriptionSubmitted',
      index: true
    },
    totalPrice: {
      type: Number,
      required: true,
      min: [0, 'Total price must be non-negative']
    },
    provider: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Facility'
    },
    orderDate: {
      type: Date,
      default: Date.now
    }
  },
  {
    timestamps: true
  }
);

const MedicineOrder = mongoose.model('MedicineOrder', medicineOrderSchema);
module.exports = MedicineOrder;

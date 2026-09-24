const mongoose = require('mongoose');

const adoptionAnimalSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Animal name is required'],
      trim: true
    },
    animalType: {
      type: String,
      required: [true, 'Animal type is required (Dog, Cat, Other)'],
      trim: true
    },
    breed: {
      type: String,
      default: 'Mixed / Indie',
      trim: true
    },
    age: {
      type: String,
      required: true,
      default: '1 Year'
    },
    gender: {
      type: String,
      enum: ['Male', 'Female', 'Unknown'],
      default: 'Unknown'
    },
    isVaccinated: {
      type: Boolean,
      default: true
    },
    isSterilized: {
      type: Boolean,
      default: true
    },
    location: {
      type: String,
      required: true,
      trim: true
    },
    shelter: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Facility',
      required: true
    },
    shelterName: {
      type: String,
      required: true
    },
    story: {
      type: String,
      default: 'Rescued and nurtured back to full health. Ready for a loving home.'
    },
    personality: [
      {
        type: String
      }
    ],
    healthSummary: {
      type: String,
      default: 'Fully vaccinated, dewormed and healthy.'
    },
    imageUrl: {
      type: String,
      required: true,
      default: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=600'
    },
    isAdopted: {
      type: Boolean,
      default: false
    },
    status: {
      type: String,
      enum: ['Available', 'Application Under Review', 'Reserved', 'Adopted', 'Unavailable'],
      default: 'Available',
      index: true
    },
    addedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    }
  },
  {
    timestamps: true
  }
);

const AdoptionAnimal = mongoose.model('AdoptionAnimal', adoptionAnimalSchema);
module.exports = AdoptionAnimal;

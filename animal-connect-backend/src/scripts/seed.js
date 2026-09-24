const mongoose = require('mongoose');
const User = require('../models/User');
const VolunteerProfile = require('../models/VolunteerProfile');
const Facility = require('../models/Facility');
const AnimalCase = require('../models/AnimalCase');
const CaseStatusHistory = require('../models/CaseStatusHistory');
const TreatmentRecord = require('../models/TreatmentRecord');
const FundingRequest = require('../models/FundingRequest');
const Donation = require('../models/Donation');
const MedicineItem = require('../models/MedicineItem');
const PetCareProvider = require('../models/PetCareProvider');
const AdoptionAnimal = require('../models/AdoptionAnimal');
const Notification = require('../models/Notification');
const connectDB = require('../config/db');

const seedData = async () => {
  try {
    await connectDB();
    console.log('[Seeder] Connected to database. Clearing existing test data...');

    // Clear collections
    await Promise.all([
      User.deleteMany({ email: { $ne: 'admin@animalconnect.org' } }),
      VolunteerProfile.deleteMany({}),
      Facility.deleteMany({}),
      AnimalCase.deleteMany({}),
      CaseStatusHistory.deleteMany({}),
      TreatmentRecord.deleteMany({}),
      FundingRequest.deleteMany({}),
      Donation.deleteMany({}),
      MedicineItem.deleteMany({}),
      PetCareProvider.deleteMany({}),
      AdoptionAnimal.deleteMany({}),
      Notification.deleteMany({})
    ]);

    console.log('[Seeder] Creating Demo Users...');
    // 1. Volunteer User
    const volunteerUser = await User.create({
      fullName: 'Harsshith Saravanan',
      email: 'harsshith@animalconnect.org',
      phone: '+91 98765 00001',
      password: 'Password@123',
      role: 'volunteer',
      isVerified: true,
      city: 'Coimbatore, TN'
    });

    await VolunteerProfile.create({
      userId: volunteerUser._id,
      capabilities: [
        'Transport animals',
        'Provide temporary care',
        'Help with medicine pickup',
        'Support adoption',
        'Donate'
      ],
      isAvailable: true,
      serviceArea: 'Coimbatore and surrounding areas',
      city: 'Coimbatore'
    });

    // 2. Hospital Owner User
    const hospitalUser = await User.create({
      fullName: 'Dr. Rajesh Kumar',
      email: 'hospital@animalconnect.org',
      phone: '+91 98765 00002',
      password: 'Password@123',
      role: 'hospital',
      isVerified: true,
      city: 'Coimbatore'
    });

    // 3. Shelter Manager User
    const shelterUser = await User.create({
      fullName: 'Priya Narayanan',
      email: 'shelter@animalconnect.org',
      phone: '+91 98765 00003',
      password: 'Password@123',
      role: 'shelter',
      isVerified: true,
      city: 'Coimbatore'
    });

    console.log('[Seeder] Creating Facilities...');
    // Facilities
    const hospitalFacility = await Facility.create({
      name: 'Companion Animal Hospital',
      type: 'hospital',
      owner: hospitalUser._id,
      phone: '+91 422 2567890',
      email: 'contact@companionanimalhospital.com',
      address: '142 Avinashi Road, Peelamedu',
      city: 'Coimbatore',
      location: {
        type: 'Point',
        coordinates: [76.9950, 11.0250]
      },
      isVerified: true,
      verificationStatus: 'verified',
      rating: 4.8,
      openHours: '24 Hours Emergency',
      isOpenNow: true,
      hasEmergency: true,
      offersSupportedCare: true,
      totalAnimalsHelped: 540,
      services: ['24/7 Emergency Care', 'Orthopedic Surgery', 'ICU & Oxygen Support', 'Digital X-Ray', 'Ultrasound'],
      imageUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=600'
    });

    const clinicFacility = await Facility.create({
      name: 'Hope Veterinary Clinic',
      type: 'clinic',
      owner: hospitalUser._id,
      phone: '+91 422 2345678',
      email: 'info@hopevetclinic.org',
      address: '88 DB Road, RS Puram',
      city: 'Coimbatore',
      location: {
        type: 'Point',
        coordinates: [76.9450, 11.0080]
      },
      isVerified: true,
      verificationStatus: 'verified',
      rating: 4.6,
      openHours: '8:00 AM - 8:00 PM',
      isOpenNow: true,
      hasEmergency: false,
      offersSupportedCare: true,
      totalAnimalsHelped: 320,
      services: ['Outpatient Consultation', 'Vaccination & Deworming', 'Minor Surgery', 'General Pathology'],
      imageUrl: 'https://images.unsplash.com/photo-1628009368231-7bb7cfcb0def?w=600'
    });

    const shelterFacility = await Facility.create({
      name: 'Coimbatore Animal Shelter & Sanctuary',
      type: 'shelter',
      owner: shelterUser._id,
      phone: '+91 422 2678901',
      email: 'care@coimbatoreanimalshelter.org',
      address: 'Near Marudhamalai Foothills',
      city: 'Coimbatore',
      location: {
        type: 'Point',
        coordinates: [76.8500, 11.0400]
      },
      isVerified: true,
      verificationStatus: 'verified',
      capacity: 80,
      currentOccupancy: 34,
      rating: 4.9,
      openHours: '9:00 AM - 6:00 PM',
      isOpenNow: true,
      hasEmergency: false,
      offersSupportedCare: true,
      totalAnimalsHelped: 890,
      services: ['Long-term Rehabilitation', 'Shelter Care', 'Adoption Counseling', 'Foster Coordination'],
      imageUrl: 'https://images.unsplash.com/photo-1548767797-d8c844163c4c?w=600'
    });

    const medicineFacility = await Facility.create({
      name: 'VetCare Medicine Hub',
      type: 'medicineProvider',
      owner: hospitalUser._id,
      phone: '+91 422 2456789',
      email: 'orders@vetcarehub.com',
      address: '22 Cross Cut Road, Gandhipuram',
      city: 'Coimbatore',
      location: {
        type: 'Point',
        coordinates: [76.9650, 11.0180]
      },
      isVerified: true,
      verificationStatus: 'verified',
      rating: 4.7,
      openHours: '8:00 AM - 10:00 PM',
      isOpenNow: true,
      hasEmergency: false,
      offersSupportedCare: true,
      services: ['Prescription Medicines', 'First Aid Supplies', 'Express Delivery'],
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600'
    });

    console.log('[Seeder] Creating Animal Cases...');
    // Animal Cases
    const case1 = await AnimalCase.create({
      caseId: 'CASE-2026-0001',
      reporter: volunteerUser._id,
      reporterName: volunteerUser.fullName,
      reporterPhone: volunteerUser.phone,
      animalType: 'Dog',
      condition: 'Critical',
      description: 'Found near roadside divider after vehicle impact. Severe right hind-leg fracture, unable to walk, heavy bleeding.',
      ageGroup: 'Adult',
      gender: 'Male',
      locationAddress: 'Race Course Road, near Thomas Park',
      landmark: 'Opposite Government Arts College',
      location: { type: 'Point', coordinates: [76.9700, 11.0050] },
      images: [
        {
          url: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=600',
          caption: 'Distress photo taken at accident site'
        }
      ],
      volunteerAction: 'Transport',
      selectedFacility: hospitalFacility._id,
      selectedFacilityName: hospitalFacility.name,
      status: 'Under Treatment',
      priority: 'Critical',
      estimatedCost: 8500,
      pawcareSupport: 4000,
      donorSupport: 3000,
      remainingCost: 1500,
      photoMatchStatus: 'matched',
      medicalNotes: [
        'Admitted on emergency stretcher',
        'X-Ray confirmed distal femur compound fracture',
        'Orthopedic pin stabilization surgery performed successfully'
      ]
    });

    await CaseStatusHistory.create({
      caseId: case1._id,
      previousStatus: 'Reported',
      newStatus: 'Under Treatment',
      changedBy: hospitalUser._id,
      changerRole: 'hospital',
      remarks: 'Admitted into emergency orthopedic ward'
    });

    // Funding request for Case 1
    await FundingRequest.create({
      fundingId: 'FUND-2026-0001',
      caseId: case1._id,
      facilityId: hospitalFacility._id,
      animalName: 'Golden Retriever Mix',
      animalImageUrl: case1.images[0].url,
      volunteerName: volunteerUser.fullName,
      hospitalName: hospitalFacility.name,
      diagnosis: 'Distal femur compound fracture with deep tissue laceration',
      treatmentDetails: 'Emergency surgical debridement, intramedullary pin fixation, antibiotic course',
      requestedAmount: 8500,
      approvedAmount: 8500,
      pawcareSupport: 4000,
      donorSupport: 3000,
      remainingAmount: 1500,
      isApproved: true,
      status: 'Partially Funded',
      checklist: {
        volunteerVerified: true,
        hospitalVerified: true,
        photosMatched: true,
        treatmentSubmitted: true,
        medicalEvidenceSubmitted: true
      },
      createdBy: hospitalUser._id
    });

    // Case 2
    const case2 = await AnimalCase.create({
      caseId: 'CASE-2026-0002',
      reporter: volunteerUser._id,
      reporterName: volunteerUser.fullName,
      reporterPhone: volunteerUser.phone,
      animalType: 'Dog',
      condition: 'Puppy/Kitten',
      description: 'Litter of two indie pups abandoned in cardboard box near dumpster. Extremely weak and shivering.',
      ageGroup: 'Young',
      gender: 'Female',
      locationAddress: 'Diwan Bahadur Road, RS Puram',
      landmark: 'Near Post Office',
      location: { type: 'Point', coordinates: [76.9480, 11.0100] },
      images: [
        {
          url: 'https://images.unsplash.com/photo-1591769225440-811ad7d6eab2?w=600',
          caption: 'Puppies found in box'
        }
      ],
      volunteerAction: 'Provide Care',
      selectedFacility: shelterFacility._id,
      selectedFacilityName: shelterFacility.name,
      status: 'Shelter Care',
      priority: 'High',
      estimatedCost: 2500,
      pawcareSupport: 1500,
      donorSupport: 1000,
      remainingCost: 0,
      photoMatchStatus: 'matched'
    });

    // Case 3
    await AnimalCase.create({
      caseId: 'CASE-2026-0003',
      reporter: volunteerUser._id,
      reporterName: volunteerUser.fullName,
      reporterPhone: volunteerUser.phone,
      animalType: 'Cat',
      condition: 'Sick',
      description: 'Stray domestic cat with severe corneal opacity and bilateral purulent eye discharge.',
      ageGroup: 'Adult',
      gender: 'Female',
      locationAddress: '7th Street, Gandhipuram',
      landmark: 'Near Central Bus Stand',
      location: { type: 'Point', coordinates: [76.9680, 11.0190] },
      images: [
        {
          url: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=600',
          caption: 'Eye infection photo'
        }
      ],
      volunteerAction: 'Need Help',
      selectedFacility: clinicFacility._id,
      selectedFacilityName: clinicFacility.name,
      status: 'Admitted',
      priority: 'Medium',
      estimatedCost: 1800,
      pawcareSupport: 800,
      donorSupport: 0,
      remainingCost: 1000
    });

    console.log('[Seeder] Creating Treatment Records...');
    await TreatmentRecord.create({
      caseId: case1._id,
      facilityId: hospitalFacility._id,
      veterinarianName: 'Dr. Rajesh Kumar (B.V.Sc & A.H)',
      licenseNumber: 'VET-TN-2018-4421',
      diagnosis: 'Distal femur compound fracture with deep tissue laceration',
      treatmentPlan: 'Emergency debridement, pin fixation surgery, post-op physiotherapy',
      medicalNotes: [
        'Vital signs stabilized on IV Ringers Lactate',
        'Pin insertion completed without complications',
        'Dressing change scheduled every 48 hours'
      ],
      prescribedMedicines: [
        { name: 'Ceftriaxone 500mg Inj', dosage: '1 vial IV', frequency: 'Twice daily', duration: '5 days' },
        { name: 'Meloxicam 0.2mg/kg', dosage: '1 ml SC', frequency: 'Once daily', duration: '3 days' },
        { name: 'Multivitamin Infusion', dosage: '5 ml', frequency: 'Once daily', duration: '5 days' }
      ],
      estimatedCost: 8500,
      actualCost: 7800,
      treatmentStatus: 'in_progress',
      recordedBy: hospitalUser._id
    });

    console.log('[Seeder] Creating Medicines Catalog...');
    await MedicineItem.insertMany([
      {
        name: 'Betadine Antiseptic Solution 500ml',
        category: 'Wound Care',
        price: 185,
        isPrescriptionRequired: false,
        providerName: 'VetCare Medicine Hub',
        provider: medicineFacility._id,
        description: 'Povidone Iodine 10% topical solution for wound disinfection and antiseptic dressing.',
        imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600',
        inStock: true
      },
      {
        name: 'Amoxicillin Antibiotic Drops 30ml',
        category: 'Antibiotics',
        price: 240,
        isPrescriptionRequired: true,
        providerName: 'VetCare Medicine Hub',
        provider: medicineFacility._id,
        description: 'Broad-spectrum antibiotic oral suspension for veterinary bacterial infections.',
        imageUrl: 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=600',
        inStock: true
      },
      {
        name: 'Calcium & Vitamin D3 Puppy Syrup 200ml',
        category: 'Supplements',
        price: 310,
        isPrescriptionRequired: false,
        providerName: 'VetCare Medicine Hub',
        provider: medicineFacility._id,
        description: 'Nutritional bone supplement for puppies and lactating female animals.',
        imageUrl: 'https://images.unsplash.com/photo-1550572017-edd951aa8f72?w=600',
        inStock: true
      },
      {
        name: 'Bandage & Sterile Gauze Kit (Pack of 5)',
        category: 'First Aid',
        price: 120,
        isPrescriptionRequired: false,
        providerName: 'VetCare Medicine Hub',
        provider: medicineFacility._id,
        description: 'Sterile cotton gauze rolls and cohesive elastic stretch bandages for dressing.',
        imageUrl: 'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=600',
        inStock: true
      },
      {
        name: 'Meloxicam Anti-inflammatory Liquid 10ml',
        category: 'Prescription',
        price: 195,
        isPrescriptionRequired: true,
        providerName: 'VetCare Medicine Hub',
        provider: medicineFacility._id,
        description: 'Non-steroidal anti-inflammatory oral suspension for pain and fever relief.',
        imageUrl: 'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=600',
        inStock: true
      }
    ]);

    console.log('[Seeder] Creating Pet Care Providers...');
    await PetCareProvider.insertMany([
      {
        user: hospitalUser._id,
        name: 'Happy Tails Pet Boarding & Daycare',
        serviceType: 'Boarding',
        rating: 4.9,
        pricePerDay: 450,
        location: 'Saravanampatti, Coimbatore',
        coordinates: [76.9920, 11.0800],
        isVerified: true,
        verificationStatus: 'verified',
        availabilityStatus: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=600',
        description: 'Spacious open play areas, climate-controlled suites, 24/7 CCTV access for pet parents.',
        phone: '+91 98401 23456'
      },
      {
        user: hospitalUser._id,
        name: 'Pawsome Grooming & Mobile Spa',
        serviceType: 'Grooming',
        rating: 4.8,
        pricePerDay: 600,
        location: 'Saibaba Colony, Coimbatore',
        coordinates: [76.9400, 11.0300],
        isVerified: true,
        verificationStatus: 'verified',
        availabilityStatus: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?w=600',
        description: 'Full medicated baths, de-shedding, tick treatment, nail trimming and styling.',
        phone: '+91 98402 34567'
      }
    ]);

    console.log('[Seeder] Creating Adoption Animals...');
    await AdoptionAnimal.insertMany([
      {
        name: 'Bruno',
        animalType: 'Dog',
        breed: 'Indie Pup',
        age: '3 Months',
        gender: 'Male',
        isVaccinated: true,
        isSterilized: false,
        location: 'Coimbatore Shelter',
        shelter: shelterFacility._id,
        shelterName: shelterFacility.name,
        story: 'Found abandoned near railway tracks. Extremely friendly, playful, and loves human companionship.',
        personality: ['Playful', 'Affectionate', 'Good with children', 'Fast learner'],
        healthSummary: 'First puppy shots completed, dewormed twice, healthy appetite.',
        imageUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=600',
        isAdopted: false,
        status: 'Available'
      },
      {
        name: 'Luna',
        animalType: 'Cat',
        breed: 'Calico Cat',
        age: '8 Months',
        gender: 'Female',
        isVaccinated: true,
        isSterilized: true,
        location: 'Coimbatore Shelter',
        shelter: shelterFacility._id,
        shelterName: shelterFacility.name,
        story: 'Surrendered after owner relocated. Very calm, indoor-trained, purrs constantly when petted.',
        personality: ['Gentle', 'Litter-trained', 'Quiet', 'Loving'],
        healthSummary: 'Spayed, fully vaccinated against FPV, healthy.',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=600',
        isAdopted: false,
        status: 'Available'
      }
    ]);

    console.log('[Seeder] Creating Initial Donations & Notifications...');
    await Donation.create({
      transactionId: 'TXN-MOCK-SEED-001',
      caseId: case1._id,
      caseTitle: 'Golden Retriever Mix Fracture Treatment',
      donor: volunteerUser._id,
      donorName: 'Harsshith Saravanan',
      donorEmail: 'harsshith@animalconnect.org',
      donorPhone: '+91 98765 00001',
      amount: 3000,
      category: 'Emergency Treatment',
      paymentStatus: 'completed',
      paymentMethod: 'mock_gateway'
    });

    await Notification.create({
      user: volunteerUser._id,
      title: 'Donation Received',
      body: 'Your contribution of ₹3000 was allocated to Case CASE-2026-0001.',
      category: 'Donation',
      caseId: case1._id
    });

    console.log('==================================================');
    console.log('  Database Seeding Completed Successfully!');
    console.log('  Created Accounts:');
    console.log('    Volunteer: harsshith@animalconnect.org / Password@123');
    console.log('    Hospital:  hospital@animalconnect.org  / Password@123');
    console.log('    Shelter:   shelter@animalconnect.org   / Password@123');
    console.log('==================================================');

    process.exit(0);
  } catch (error) {
    console.error('[Seeder Failed]', error);
    process.exit(1);
  }
};

seedData();

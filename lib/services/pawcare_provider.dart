import 'package:flutter/material.dart';
import '../models/animal_case.dart';
import '../models/facility.dart';
import '../models/funding_request.dart';
import '../models/donation.dart';
import '../models/medicine.dart';
import '../models/pet_care.dart';
import '../models/adoption.dart';
import '../models/notification.dart';
import 'mock_data.dart';

class PawCareProvider extends ChangeNotifier {
  // User Profile Data
  String userName = 'Harsshith Saravanan';
  String userPhone = '+91 98765 00001';
  String currentLocation = 'Coimbatore, TN';
  bool isVolunteer = true;
  List<String> volunteerCapabilities = [
    'I can transport animals',
    'I can provide temporary care',
    'I can help with medicine pickup',
    'I can support adoption',
    'I can donate',
  ];

  // Admin Demo Mode
  bool isAdminDemoMode = false;

  // Datasets
  late List<Facility> _facilities;
  late List<AnimalCase> _cases;
  late List<FundingRequest> _fundingRequests;
  late List<Donation> _donations;
  late List<MedicineItem> _medicines;
  late List<MedicineOrder> _medicineOrders;
  late List<PetCareProvider> _petCareProviders;
  late List<AdoptionAnimal> _adoptionAnimals;
  late List<AdoptionApplication> _adoptionApplications;
  late List<AppNotification> _notifications;

  PawCareProvider() {
    _initData();
  }

  void _initData() {
    _facilities = MockData.getInitialFacilities();
    _cases = MockData.getInitialCases();
    _fundingRequests = MockData.getInitialFundingRequests();
    _donations = MockData.getInitialDonations();
    _medicines = MockData.getInitialMedicines();
    _medicineOrders = MockData.getInitialMedicineOrders();
    _petCareProviders = MockData.getInitialPetCareProviders();
    _adoptionAnimals = MockData.getInitialAdoptionAnimals();
    _adoptionApplications = [];
    _notifications = MockData.getInitialNotifications();
  }

  // Getters
  List<Facility> get facilities => List.unmodifiable(_facilities);
  List<Facility> get hospitalsAndClinics => _facilities
      .where((f) => f.type == FacilityType.hospital || f.type == FacilityType.clinic)
      .toList();
  List<Facility> get shelters =>
      _facilities.where((f) => f.type == FacilityType.shelter).toList();
  List<AnimalCase> get cases => List.unmodifiable(_cases);
  List<AnimalCase> get activeCases => _cases
      .where((c) =>
          c.status != CaseStatus.treatmentCompleted &&
          c.status != CaseStatus.adopted)
      .toList();
  List<AnimalCase> get completedCases => _cases
      .where((c) =>
          c.status == CaseStatus.treatmentCompleted ||
          c.status == CaseStatus.adopted)
      .toList();
  List<FundingRequest> get fundingRequests => List.unmodifiable(_fundingRequests);
  List<Donation> get donations => List.unmodifiable(_donations);
  List<MedicineItem> get medicines => List.unmodifiable(_medicines);
  List<MedicineOrder> get medicineOrders => List.unmodifiable(_medicineOrders);
  List<PetCareProvider> get petCareProviders => List.unmodifiable(_petCareProviders);
  List<AdoptionAnimal> get adoptionAnimals => List.unmodifiable(_adoptionAnimals);
  List<AdoptionApplication> get adoptionApplications => List.unmodifiable(_adoptionApplications);
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  double get totalFundRaised =>
      _donations.fold(0.0, (sum, item) => sum + item.amount) + 485000.0;

  int get totalAnimalsHelped => 1280 + _cases.length;

  // Actions & Mutators

  void toggleAdminDemoMode() {
    isAdminDemoMode = !isAdminDemoMode;
    notifyListeners();
  }

  void toggleVolunteerStatus(bool value) {
    isVolunteer = value;
    notifyListeners();
  }

  void updateVolunteerCapabilities(List<String> capabilities) {
    volunteerCapabilities = List.from(capabilities);
    notifyListeners();
  }

  void updateLocation(String newLocation) {
    currentLocation = newLocation;
    notifyListeners();
  }

  // Report New Animal Case
  AnimalCase createNewCase({
    required String animalType,
    required String condition,
    required String description,
    required String ageGroup,
    required String locationAddress,
    required String landmark,
    required String volunteerAction,
    required String selectedFacilityId,
    required String selectedFacilityName,
    required String imageUrl,
  }) {
    final newId = 'PC-2026-00${125 + _cases.length}';
    final newCase = AnimalCase(
      id: newId,
      animalType: animalType,
      condition: condition,
      description: description,
      ageGroup: ageGroup,
      locationAddress: locationAddress,
      landmark: landmark,
      volunteerAction: volunteerAction,
      selectedFacilityId: selectedFacilityId,
      selectedFacilityName: selectedFacilityName,
      status: CaseStatus.reported,
      reporterName: userName,
      reporterPhone: userPhone,
      imageUrl: imageUrl.isEmpty
          ? 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80'
          : imageUrl,
      createdAt: DateTime.now(),
      estimatedCost: 6500.0,
      pawcareSupport: 4000.0,
      donorSupport: 1500.0,
      remainingCost: 1000.0,
      medicalNotes: ['Report submitted by volunteer. Facility notified for triage.'],
    );

    _cases.insert(0, newCase);

    // Also add to notifications
    _notifications.insert(
      0,
      AppNotification(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'New Case Reported ($newId)',
        body: 'Report for $animalType ($condition) submitted successfully.',
        timestamp: DateTime.now(),
        category: 'Case',
        caseId: newId,
      ),
    );

    notifyListeners();
    return newCase;
  }

  void updateCaseStatus(String caseId, CaseStatus newStatus) {
    final index = _cases.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      _cases[index].status = newStatus;
      _cases[index].medicalNotes.add('Status updated to ${newStatus.displayName}');

      _notifications.insert(
        0,
        AppNotification(
          id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Case Status Updated',
          body: 'Case $caseId status changed to ${newStatus.displayName}.',
          timestamp: DateTime.now(),
          category: 'Case',
          caseId: caseId,
        ),
      );

      notifyListeners();
    }
  }

  // Add Donation
  Donation recordDonation({
    String? caseId,
    String? caseTitle,
    required double amount,
    required String category,
  }) {
    final newId = 'DON-${106 + _donations.length}';
    final txnId = 'TXN-${998129 + _donations.length}';

    final donation = Donation(
      id: newId,
      transactionId: txnId,
      caseId: caseId,
      caseTitle: caseTitle ?? 'General AnimalConnect Animal Support',
      donorName: userName,
      amount: amount,
      date: DateTime.now(),
      category: category,
    );

    _donations.insert(0, donation);

    // If case ID present, update case donor support
    if (caseId != null) {
      final caseIndex = _cases.indexWhere((c) => c.id == caseId);
      if (caseIndex != -1) {
        final currentCase = _cases[caseIndex];
        final updatedDonorSupport = currentCase.donorSupport + amount;
        final updatedRemaining = (currentCase.estimatedCost - currentCase.pawcareSupport - updatedDonorSupport)
            .clamp(0.0, double.infinity);

        _cases[caseIndex] = AnimalCase(
          id: currentCase.id,
          animalType: currentCase.animalType,
          condition: currentCase.condition,
          description: currentCase.description,
          ageGroup: currentCase.ageGroup,
          locationAddress: currentCase.locationAddress,
          landmark: currentCase.landmark,
          volunteerAction: currentCase.volunteerAction,
          selectedFacilityId: currentCase.selectedFacilityId,
          selectedFacilityName: currentCase.selectedFacilityName,
          status: currentCase.status,
          reporterName: currentCase.reporterName,
          reporterPhone: currentCase.reporterPhone,
          imageUrl: currentCase.imageUrl,
          createdAt: currentCase.createdAt,
          estimatedCost: currentCase.estimatedCost,
          pawcareSupport: currentCase.pawcareSupport,
          donorSupport: updatedDonorSupport,
          remainingCost: updatedRemaining,
          medicalNotes: currentCase.medicalNotes,
        );
      }
    }

    _notifications.insert(
      0,
      AppNotification(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Donation Confirmed (₹${amount.toStringAsFixed(0)})',
        body: 'Thank you! Your donation for ${donation.caseTitle} was recorded.',
        timestamp: DateTime.now(),
        category: 'Donation',
      ),
    );

    notifyListeners();
    return donation;
  }

  // Submit Medicine Order
  MedicineOrder submitMedicineOrder({
    String? caseId,
    required List<MedicineItem> items,
    required String deliveryAddress,
    required String prescriptionUrl,
  }) {
    final orderNum = 9942 + _medicineOrders.length;
    final totalPrice = items.fold(0.0, (sum, i) => sum + i.price);

    final order = MedicineOrder(
      id: 'ORD-${706 + _medicineOrders.length}',
      orderId: 'PC-MED-$orderNum',
      caseId: caseId,
      items: items,
      deliveryAddress: deliveryAddress,
      prescriptionUrl: prescriptionUrl,
      status: prescriptionUrl.isNotEmpty
          ? MedicineOrderStatus.prescriptionSubmitted
          : MedicineOrderStatus.verified,
      orderDate: DateTime.now(),
      totalPrice: totalPrice,
    );

    _medicineOrders.insert(0, order);

    _notifications.insert(
      0,
      AppNotification(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Medicine Order Placed (${order.orderId})',
        body: 'Order for ${items.length} item(s) placed successfully.',
        timestamp: DateTime.now(),
        category: 'General',
      ),
    );

    notifyListeners();
    return order;
  }

  // Submit Adoption Application
  AdoptionApplication submitAdoptionApplication({
    required String animalId,
    required String animalName,
    required String livingSituation,
    required String petExperience,
    required String reason,
  }) {
    final appNum = 10 + _adoptionApplications.length;
    final application = AdoptionApplication(
      id: 'app-${101 + _adoptionApplications.length}',
      applicationId: 'AD-2026-0$appNum',
      animalId: animalId,
      animalName: animalName,
      applicantName: userName,
      applicantPhone: userPhone,
      livingSituation: livingSituation,
      petExperience: petExperience,
      reason: reason,
      status: 'Submitted',
      submittedAt: DateTime.now(),
    );

    _adoptionApplications.insert(0, application);

    _notifications.insert(
      0,
      AppNotification(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Adoption Application Submitted',
        body: 'Your application for $animalName (${application.applicationId}) is under shelter review.',
        timestamp: DateTime.now(),
        category: 'Adoption',
      ),
    );

    notifyListeners();
    return application;
  }

  // Register New Facility
  void registerFacility(Facility newFacility) {
    _facilities.add(newFacility);

    _notifications.insert(
      0,
      AppNotification(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Facility Registration Submitted',
        body: '${newFacility.name} application is pending verification.',
        timestamp: DateTime.now(),
        category: 'General',
      ),
    );

    notifyListeners();
  }

  // Admin Actions
  void verifyFacility(String facilityId) {
    final index = _facilities.indexWhere((f) => f.id == facilityId);
    if (index != -1) {
      final f = _facilities[index];
      _facilities[index] = Facility(
        id: f.id,
        name: f.name,
        type: f.type,
        isVerified: true,
        imageUrl: f.imageUrl,
        address: f.address,
        city: f.city,
        distanceKm: f.distanceKm,
        phone: f.phone,
        rating: f.rating,
        openHours: f.openHours,
        isOpenNow: f.isOpenNow,
        hasEmergency: f.hasEmergency,
        offersSupportedCare: f.offersSupportedCare,
        services: f.services,
        totalAnimalsHelped: f.totalAnimalsHelped,
        availableCapacity: f.availableCapacity,
      );
      notifyListeners();
    }
  }

  void approveFunding(String requestId) {
    final index = _fundingRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _fundingRequests[index].isApproved = true;
      notifyListeners();
    }
  }

  // Notifications
  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }
}

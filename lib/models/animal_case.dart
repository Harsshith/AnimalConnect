enum CaseStatus {
  reported,
  facilitySelected,
  admitted,
  underTreatment,
  fundingReview,
  treatmentCompleted,
  shelterCare,
  readyForAdoption,
  adopted,
}

extension CaseStatusExtension on CaseStatus {
  String get displayName {
    switch (this) {
      case CaseStatus.reported:
        return 'Reported';
      case CaseStatus.facilitySelected:
        return 'Facility Selected';
      case CaseStatus.admitted:
        return 'Admitted';
      case CaseStatus.underTreatment:
        return 'Under Treatment';
      case CaseStatus.fundingReview:
        return 'Funding Review';
      case CaseStatus.treatmentCompleted:
        return 'Treatment Completed';
      case CaseStatus.shelterCare:
        return 'Shelter Care';
      case CaseStatus.readyForAdoption:
        return 'Ready for Adoption';
      case CaseStatus.adopted:
        return 'Adopted';
    }
  }

  int get stepIndex {
    switch (this) {
      case CaseStatus.reported:
        return 0;
      case CaseStatus.facilitySelected:
        return 1;
      case CaseStatus.admitted:
        return 2;
      case CaseStatus.underTreatment:
        return 3;
      case CaseStatus.fundingReview:
        return 4;
      case CaseStatus.treatmentCompleted:
        return 5;
      case CaseStatus.shelterCare:
        return 6;
      case CaseStatus.readyForAdoption:
        return 6;
      case CaseStatus.adopted:
        return 7;
    }
  }
}

class AnimalCase {
  final String id;
  final String animalType; // Dog, Cat, Other
  final String condition; // Critical, Injured, Sick, Healthy, Abandoned, Puppy/Kitten
  final String description;
  final String ageGroup; // Young, Adult, Senior, Unknown
  final String locationAddress;
  final String landmark;
  final String volunteerAction; // Transport, Need Help, Temp Care
  final String selectedFacilityId;
  final String selectedFacilityName;
  CaseStatus status;
  final String reporterName;
  final String reporterPhone;
  final String imageUrl;
  final DateTime createdAt;
  final double estimatedCost;
  final double pawcareSupport;
  final double donorSupport;
  final double remainingCost;
  final List<String> medicalNotes;

  AnimalCase({
    required this.id,
    required this.animalType,
    required this.condition,
    required this.description,
    required this.ageGroup,
    required this.locationAddress,
    required this.landmark,
    required this.volunteerAction,
    required this.selectedFacilityId,
    required this.selectedFacilityName,
    required this.status,
    required this.reporterName,
    required this.reporterPhone,
    required this.imageUrl,
    required this.createdAt,
    this.estimatedCost = 0.0,
    this.pawcareSupport = 0.0,
    this.donorSupport = 0.0,
    this.remainingCost = 0.0,
    this.medicalNotes = const [],
  });
}

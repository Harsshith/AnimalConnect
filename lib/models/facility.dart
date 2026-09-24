enum FacilityType {
  hospital,
  clinic,
  shelter,
  petCare,
  medicineProvider,
}

extension FacilityTypeExtension on FacilityType {
  String get displayName {
    switch (this) {
      case FacilityType.hospital:
        return 'Veterinary Hospital';
      case FacilityType.clinic:
        return 'Pet Clinic';
      case FacilityType.shelter:
        return 'Animal Shelter';
      case FacilityType.petCare:
        return 'Pet Care Provider';
      case FacilityType.medicineProvider:
        return 'Medicine Provider';
    }
  }
}

class Facility {
  final String id;
  final String name;
  final FacilityType type;
  final bool isVerified;
  final String imageUrl;
  final String address;
  final String city;
  final double distanceKm;
  final String phone;
  final double rating;
  final String openHours;
  final bool isOpenNow;
  final bool hasEmergency;
  final bool offersSupportedCare;
  final List<String> services;
  final int totalAnimalsHelped;
  final int availableCapacity;

  Facility({
    required this.id,
    required this.name,
    required this.type,
    required this.isVerified,
    required this.imageUrl,
    required this.address,
    required this.city,
    required this.distanceKm,
    required this.phone,
    required this.rating,
    required this.openHours,
    required this.isOpenNow,
    required this.hasEmergency,
    this.offersSupportedCare = true,
    required this.services,
    this.totalAnimalsHelped = 0,
    this.availableCapacity = 0,
  });
}

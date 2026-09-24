class PetCareProvider {
  final String id;
  final String name;
  final String serviceType; // Boarding, Grooming, Foster Care, Pet Walking
  final double rating;
  final double pricePerDay;
  final String location;
  final bool isVerified;
  final String availabilityStatus; // Available, Fully Booked
  final String imageUrl;
  final String description;
  final String phone;

  PetCareProvider({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.rating,
    required this.pricePerDay,
    required this.location,
    required this.isVerified,
    required this.availabilityStatus,
    required this.imageUrl,
    required this.description,
    required this.phone,
  });
}

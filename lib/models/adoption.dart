class AdoptionAnimal {
  final String id;
  final String name;
  final String animalType; // Dog, Cat, Other
  final String breed;
  final String age;
  final String gender;
  final bool isVaccinated;
  final bool isSterilized;
  final String location;
  final String shelterName;
  final String shelterId;
  final String story;
  final List<String> personality;
  final String healthSummary;
  final String imageUrl;
  bool isAdopted;

  AdoptionAnimal({
    required this.id,
    required this.name,
    required this.animalType,
    required this.breed,
    required this.age,
    required this.gender,
    required this.isVaccinated,
    required this.isSterilized,
    required this.location,
    required this.shelterName,
    required this.shelterId,
    required this.story,
    required this.personality,
    required this.healthSummary,
    required this.imageUrl,
    this.isAdopted = false,
  });
}

class AdoptionApplication {
  final String id;
  final String applicationId;
  final String animalId;
  final String animalName;
  final String applicantName;
  final String applicantPhone;
  final String livingSituation;
  final String petExperience;
  final String reason;
  final String status; // Submitted, Under Review, Approved
  final DateTime submittedAt;

  AdoptionApplication({
    required this.id,
    required this.applicationId,
    required this.animalId,
    required this.animalName,
    required this.applicantName,
    required this.applicantPhone,
    required this.livingSituation,
    required this.petExperience,
    required this.reason,
    required this.status,
    required this.submittedAt,
  });
}

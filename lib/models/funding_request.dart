class VerificationChecklist {
  final bool volunteerVerified;
  final bool hospitalVerified;
  final bool photosMatched;
  final bool treatmentSubmitted;
  final bool medicalEvidenceSubmitted;

  const VerificationChecklist({
    this.volunteerVerified = true,
    this.hospitalVerified = true,
    this.photosMatched = true,
    this.treatmentSubmitted = true,
    this.medicalEvidenceSubmitted = true,
  });

  bool get isFullyVerified =>
      volunteerVerified &&
      hospitalVerified &&
      photosMatched &&
      treatmentSubmitted &&
      medicalEvidenceSubmitted;
}

class FundingRequest {
  final String id;
  final String caseId;
  final String animalName;
  final String animalImageUrl;
  final String volunteerName;
  final String hospitalName;
  final String diagnosis;
  final String treatmentDetails;
  final double estimatedCost;
  double pawcareSupport;
  double donorSupport;
  double remainingAmount;
  final VerificationChecklist checklist;
  bool isApproved;

  FundingRequest({
    required this.id,
    required this.caseId,
    required this.animalName,
    required this.animalImageUrl,
    required this.volunteerName,
    required this.hospitalName,
    required this.diagnosis,
    required this.treatmentDetails,
    required this.estimatedCost,
    required this.pawcareSupport,
    required this.donorSupport,
    required this.remainingAmount,
    this.checklist = const VerificationChecklist(),
    this.isApproved = true,
  });
}

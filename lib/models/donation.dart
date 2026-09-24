class Donation {
  final String id;
  final String transactionId;
  final String? caseId;
  final String? caseTitle;
  final String donorName;
  final double amount;
  final DateTime date;
  final String category; // Emergency Treatment, Shelter Care, Medicine Support, General Animal Care

  Donation({
    required this.id,
    required this.transactionId,
    this.caseId,
    this.caseTitle,
    required this.donorName,
    required this.amount,
    required this.date,
    required this.category,
  });
}

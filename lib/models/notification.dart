class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  final String category; // Case, Funding, Donation, Adoption, General
  final String? caseId;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    required this.category,
    this.caseId,
  });
}

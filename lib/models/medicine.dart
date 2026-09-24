class MedicineItem {
  final String id;
  final String name;
  final String category; // Wound Care, Antibiotics, Supplements, First Aid, Prescription
  final double price;
  final bool isPrescriptionRequired;
  final String providerName;
  final String description;
  final String imageUrl;

  MedicineItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.isPrescriptionRequired,
    required this.providerName,
    required this.description,
    required this.imageUrl,
  });
}

enum MedicineOrderStatus {
  prescriptionSubmitted,
  verified,
  preparing,
  outForDelivery,
  delivered,
}

extension MedicineOrderStatusExtension on MedicineOrderStatus {
  String get displayName {
    switch (this) {
      case MedicineOrderStatus.prescriptionSubmitted:
        return 'Prescription Submitted';
      case MedicineOrderStatus.verified:
        return 'Verified by Pharmacist';
      case MedicineOrderStatus.preparing:
        return 'Preparing Order';
      case MedicineOrderStatus.outForDelivery:
        return 'Out for Delivery';
      case MedicineOrderStatus.delivered:
        return 'Delivered';
    }
  }

  int get stepIndex {
    switch (this) {
      case MedicineOrderStatus.prescriptionSubmitted:
        return 0;
      case MedicineOrderStatus.verified:
        return 1;
      case MedicineOrderStatus.preparing:
        return 2;
      case MedicineOrderStatus.outForDelivery:
        return 3;
      case MedicineOrderStatus.delivered:
        return 4;
    }
  }
}

class MedicineOrder {
  final String id;
  final String orderId;
  final String? caseId;
  final List<MedicineItem> items;
  final String deliveryAddress;
  final String prescriptionUrl;
  MedicineOrderStatus status;
  final DateTime orderDate;
  final double totalPrice;

  MedicineOrder({
    required this.id,
    required this.orderId,
    this.caseId,
    required this.items,
    required this.deliveryAddress,
    required this.prescriptionUrl,
    required this.status,
    required this.orderDate,
    required this.totalPrice,
  });
}

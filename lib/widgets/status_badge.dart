import 'package:flutter/material.dart';
import '../models/animal_case.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final CaseStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case CaseStatus.reported:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case CaseStatus.facilitySelected:
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF3730A3);
        break;
      case CaseStatus.admitted:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0369A1);
        break;
      case CaseStatus.underTreatment:
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFFC2410C);
        break;
      case CaseStatus.fundingReview:
        bg = const Color(0xFFFCE7F3);
        fg = const Color(0xFFBE185D);
        break;
      case CaseStatus.treatmentCompleted:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case CaseStatus.shelterCare:
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF6B21A8);
        break;
      case CaseStatus.readyForAdoption:
        bg = const Color(0xFFCCFBF1);
        fg = const Color(0xFF0F766E);
        break;
      case CaseStatus.adopted:
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF047857);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

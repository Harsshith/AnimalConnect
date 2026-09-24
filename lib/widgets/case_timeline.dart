import 'package:flutter/material.dart';
import '../models/animal_case.dart';
import '../theme/app_colors.dart';

class CaseTimeline extends StatelessWidget {
  final CaseStatus currentStatus;

  const CaseTimeline({super.key, required this.currentStatus});

  static const List<Map<String, String>> steps = [
    {'title': 'Case Reported', 'desc': 'Animal report submitted with photo & details'},
    {'title': 'Volunteer Confirmed', 'desc': 'Volunteer assigned for transport & care'},
    {'title': 'Hospital Selected', 'desc': 'Verified facility selected & notified'},
    {'title': 'Animal Admitted', 'desc': 'Animal safely arrived & admitted to facility'},
    {'title': 'Under Treatment', 'desc': 'Veterinary triage, surgery & therapy ongoing'},
    {'title': 'Funding Review', 'desc': 'AnimalConnect & donor support verified'},
    {'title': 'Treatment Completed', 'desc': 'Animal fully recovered & discharged'},
    {'title': 'Recovery & Adoption', 'desc': 'Placed in shelter or adopted into a loving home'},
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = currentStatus.stepIndex;

    return Column(
      children: List.generate(steps.length, (index) {
        final isPassed = index < currentIndex;
        final isCurrent = index == currentIndex;
        final isFuture = index > currentIndex;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline Node & Connector Line Column
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPassed
                          ? AppColors.greenAccent
                          : isCurrent
                              ? AppColors.actionOrange
                              : Colors.grey.shade200,
                      border: isCurrent
                          ? Border.all(color: AppColors.orangeContainer, width: 3)
                          : null,
                    ),
                    child: Center(
                      child: isPassed
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : isCurrent
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 36,
                      color: isPassed ? AppColors.greenAccent : Colors.grey.shade300,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Title & Description Column
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[index]['title']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCurrent || isPassed
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isCurrent
                            ? AppColors.actionOrange
                            : isPassed
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      steps[index]['desc']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isFuture
                            ? AppColors.textMuted
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/animal_case.dart';
import '../../theme/app_colors.dart';
import '../../widgets/pawcare_button.dart';
import '../cases/case_detail_screen.dart';
import '../main_navigation_screen.dart';

class CaseSuccessScreen extends StatelessWidget {
  final AnimalCase createdCase;

  const CaseSuccessScreen({super.key, required this.createdCase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon Animation / Container
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.greenContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: AppColors.greenAccent,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Case Created Successfully',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your report has been received and routed to verified nearby facilities.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),

              // Case Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Case ID',
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                        Text(
                          createdCase.id,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Current Status',
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Volunteer Assigned',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selected Facility',
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                        Expanded(
                          child: Text(
                            createdCase.selectedFacilityName,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Action Buttons
              PawCareButton(
                text: 'Track Case',
                type: PawCareButtonType.orange,
                icon: Icons.timeline,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => CaseDetailScreen(animalCase: createdCase),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              PawCareButton(
                text: 'Back to Home',
                type: PawCareButtonType.outline,
                icon: Icons.home,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(initialIndex: 0),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class WelfareProgramScreen extends StatelessWidget {
  const WelfareProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Animal Welfare Programs'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Core Alignment Card (Requirement #21)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.account_balance, color: AppColors.primaryBlue, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Collaboration & Program Support',
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Text('Partner Program Framework', style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'AnimalConnect is designed to support collaboration with authorized government bodies, municipal corporations, local authorities and animal-welfare programs.',
                    style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Key Program Objectives
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Supported Program Objectives',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  _buildProgramPoint('Animal Birth Control (ABC) Sterilization Drives'),
                  _buildProgramPoint('Anti-Rabies Vaccination (ARV) Campaigns'),
                  _buildProgramPoint('Disaster & Monsoon Animal Rescue Support'),
                  _buildProgramPoint('Trauma Ambulance Route Optimization'),
                  _buildProgramPoint('Cattle & Stray Sanctuary Placement'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status Notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.greenContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.tealLight.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.secondary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Status: Potential Program Support & Authorized Partner Alignment.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.primaryBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

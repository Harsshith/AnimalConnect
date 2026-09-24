import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/animal_case.dart';
import '../../services/pawcare_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/case_timeline.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/pawcare_image.dart';
import '../../widgets/pawcare_button.dart';
import '../funding/treatment_funding_screen.dart';

class CaseDetailScreen extends StatelessWidget {
  final AnimalCase animalCase;

  const CaseDetailScreen({super.key, required this.animalCase});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PawCareProvider>(context);

    // Find funding request for this case if available
    final fundingReq = provider.fundingRequests.firstWhere(
      (r) => r.caseId == animalCase.id,
      orElse: () => provider.fundingRequests.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Case Tracking ${animalCase.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Case link copied: https://pawcare.app/case/${animalCase.id}')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animal Photo Banner & Basic Details
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppColors.softShadow,
              ),
              child: Row(
                children: [
                  PawCareImage(
                    imageUrl: animalCase.imageUrl,
                    width: 90,
                    height: 90,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              animalCase.id,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            StatusBadge(status: animalCase.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${animalCase.animalType} â€¢ ${animalCase.condition}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                animalCase.locationAddress,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reported: ${DateFormat('dd MMM yyyy, hh:mm a').format(animalCase.createdAt)}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons Bar (View Medical Details, View Funding, Contact Facility)
            Row(
              children: [
                Expanded(
                  child: PawCareButton(
                    text: 'Medical Notes',
                    icon: Icons.medical_services_outlined,
                    type: PawCareButtonType.outline,
                    onPressed: () {
                      _showMedicalDetailsModal(context);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PawCareButton(
                    text: 'View Funding',
                    icon: Icons.volunteer_activism,
                    type: PawCareButtonType.secondary,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TreatmentFundingScreen(fundingRequest: fundingReq),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            PawCareButton(
              text: 'Contact Facility (${animalCase.selectedFacilityName})',
              icon: Icons.phone,
              type: PawCareButtonType.primary,
              onPressed: () {
                _showContactModal(context);
              },
            ),
            const SizedBox(height: 20),

            // Interactive 8-step Timeline
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Treatment Progress Timeline',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Icon(Icons.timeline, color: AppColors.primaryBlue),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CaseTimeline(currentStatus: animalCase.status),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Volunteer & Hospital Info Cards
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assigned Care Entities',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryContainer,
                      child: Icon(Icons.person, color: AppColors.primaryBlue),
                    ),
                    title: Text('Volunteer: ${animalCase.reporterName}'),
                    subtitle: Text('Contact: ${animalCase.reporterPhone}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.greenContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Verified', style: TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.orangeContainer,
                      child: Icon(Icons.local_hospital, color: AppColors.actionOrange),
                    ),
                    title: Text(animalCase.selectedFacilityName),
                    subtitle: const Text('Primary Treatment Center'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMedicalDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Medical Details & Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...animalCase.medicalNotes.map(
                (note) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.medical_information, size: 16, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          note,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showContactModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(animalCase.selectedFacilityName),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Facility Emergency Line:'),
            SizedBox(height: 4),
            Text(
              '+91 98765 43210',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
            SizedBox(height: 12),
            Text('Operating Hours: 24/7 Open'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulating call to facility desk...')),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('Call Facility'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/facility.dart';
import '../../theme/app_colors.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/pawcare_image.dart';
import '../../widgets/pawcare_button.dart';
import '../report_animal/report_animal_flow_screen.dart';

class FacilityDetailScreen extends StatelessWidget {
  final Facility facility;

  const FacilityDetailScreen({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Sliver Cover Image App Bar
          SliverAppBar(
            expandedHeight: 220.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PawCareImage(
                    imageUrl: facility.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: facility.isOpenNow ? AppColors.success : AppColors.danger,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            facility.isOpenNow ? 'Open Now' : 'Closed',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        if (facility.isVerified) const VerifiedBadge(showText: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Body Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  facility.name,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${facility.type.displayName} â€¢ ${facility.city}',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // Primary Quick Action Buttons (Call, Directions, Select for Case)
                Row(
                  children: [
                    Expanded(
                      child: PawCareButton(
                        text: 'Call Facility',
                        icon: Icons.phone,
                        type: PawCareButtonType.outline,
                        onPressed: () {
                          _showCallDialog(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PawCareButton(
                        text: 'Directions',
                        icon: Icons.directions,
                        type: PawCareButtonType.outline,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening maps route to ${facility.address}...')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                PawCareButton(
                  text: 'Select for Animal Case',
                  icon: Icons.local_hospital,
                  type: PawCareButtonType.orange,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ReportAnimalFlowScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Information Cards
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Facility Overview',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.location_on, 'Address', facility.address),
                      _buildInfoRow(Icons.phone, 'Phone Number', facility.phone),
                      _buildInfoRow(Icons.access_time, 'Opening Hours', facility.openHours),
                      _buildInfoRow(
                        Icons.local_hospital,
                        'Emergency Service',
                        facility.hasEmergency ? '24/7 Trauma Emergency Unit' : 'Standard Appointment Only',
                      ),
                      _buildInfoRow(
                        Icons.volunteer_activism,
                        'Treatment Support',
                        facility.offersSupportedCare
                            ? 'Eligible for AnimalConnect & Donor Support'
                            : 'Standard Rates Apply',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Services Provided
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Specialized Services Provided',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: facility.services.map((srv) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle, size: 14, color: AppColors.primaryBlue),
                                const SizedBox(width: 6),
                                Text(
                                  srv,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call ${facility.name}'),
        content: Text('Phone number: ${facility.phone}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${facility.phone}...')),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('Call Now'),
          ),
        ],
      ),
    );
  }
}

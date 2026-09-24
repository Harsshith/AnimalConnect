import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pawcare_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/section_header.dart';
import '../../widgets/facility_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/pawcare_image.dart';
import '../../widgets/pawcare_button.dart';
import '../report_animal/report_animal_flow_screen.dart';
import '../cases/case_detail_screen.dart';
import '../facilities/facility_detail_screen.dart';
import '../facilities/facility_list_screen.dart';
import '../funding/treatment_funding_screen.dart';
import '../notifications/notifications_screen.dart';
import '../welfare_program/welfare_program_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PawCareProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.pets, color: AppColors.primaryBlue, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              'AnimalConnect',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        actions: [
          // Demo Admin Switch Toggle
          IconButton(
            icon: Icon(
              provider.isAdminDemoMode ? Icons.admin_panel_settings : Icons.shield_outlined,
              color: provider.isAdminDemoMode ? AppColors.actionOrange : AppColors.textPrimary,
            ),
            tooltip: provider.isAdminDemoMode ? 'Admin Mode Active' : 'Switch to Demo Admin',
            onPressed: () {
              if (provider.isAdminDemoMode) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                );
              } else {
                provider.toggleAdminDemoMode();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Demo Admin Mode Activated! Access Admin Dashboard.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          // Notification Bell with Badge
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none_outlined, color: AppColors.textPrimary),
                if (provider.unreadNotificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.actionOrange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${provider.unreadNotificationCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Mode Banner if Enabled
            if (provider.isAdminDemoMode)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.orangeContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.orangeLight),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: AppColors.actionOrange, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Demo Admin Mode Active • Tap to open Verification Dashboard',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.actionOrange,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.actionOrange, size: 18),
                    ],
                  ),
                ),
              ),

            // Header Greeting & Location Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning 👋',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      provider.userName.split(' ').first,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                // Location Selector Dropdown UI
                GestureDetector(
                  onTap: () {
                    _showLocationPicker(context, provider);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppColors.primaryBlue),
                        const SizedBox(width: 4),
                        Text(
                          provider.currentLocation,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Large Hero Card "An animal needs help?"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.mediumShadow,
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(
                      Icons.pets,
                      size: 110,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.actionOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'EMERGENCY RESCUE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'An animal needs help?',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Report injured, sick or abandoned animals immediately to notify verified hospitals.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReportAnimalFlowScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.actionOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add_a_photo, size: 18),
                        label: const Text(
                          'Report an Animal',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Actions Grid
            Row(
              children: [
                _buildQuickActionItem(
                  context: context,
                  icon: Icons.report_problem,
                  color: AppColors.actionOrange,
                  label: 'Report Animal',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ReportAnimalFlowScreen()),
                    );
                  },
                ),
                _buildQuickActionItem(
                  context: context,
                  icon: Icons.local_hospital,
                  color: AppColors.primaryBlue,
                  label: 'Hospitals',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FacilityListScreen(
                          initialFilter: 'Hospital',
                        ),
                      ),
                    );
                  },
                ),
                _buildQuickActionItem(
                  context: context,
                  icon: Icons.medical_services,
                  color: AppColors.secondary,
                  label: 'Clinics',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FacilityListScreen(
                          initialFilter: 'Clinic',
                        ),
                      ),
                    );
                  },
                ),
                _buildQuickActionItem(
                  context: context,
                  icon: Icons.home_work,
                  color: Colors.purple.shade600,
                  label: 'Shelters',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FacilityListScreen(
                          initialFilter: 'Shelter',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Statistics Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatCard(
                    title: 'Active Cases',
                    value: '${provider.activeCases.length}',
                    subtitle: 'Being treated',
                    icon: Icons.assignment_late,
                    color: AppColors.actionOrange,
                  ),
                  _buildStatCard(
                    title: 'Animals Helped',
                    value: '${provider.totalAnimalsHelped}+',
                    subtitle: 'Lifetime rescues',
                    icon: Icons.pets,
                    color: AppColors.secondary,
                  ),
                  _buildStatCard(
                    title: 'Treatment Fund',
                    value: '₹${(provider.totalFundRaised / 1000).toStringAsFixed(0)}k+',
                    subtitle: 'Verified support',
                    icon: Icons.volunteer_activism,
                    color: AppColors.primaryBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Government / Program Support Info Card (Section #21 Requirement)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WelfareProgramScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.greenContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.tealLight.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Animal Welfare Programs',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'AnimalConnect collaborates with authorized local authorities & partner welfare programs for eligible care cases.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.secondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nearby Verified Care Section
            SectionHeader(
              title: 'Nearby Verified Care',
              subtitle: 'Hospitals, clinics & shelters near you',
              actionText: 'View All',
              onActionTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FacilityListScreen(initialFilter: 'All'),
                  ),
                );
              },
            ),
            SizedBox(
              height: 190,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.facilities.length,
                itemBuilder: (context, index) {
                  final facility = provider.facilities[index];
                  return FacilityCard(
                    facility: facility,
                    compact: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FacilityDetailScreen(facility: facility),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Cases Near You Section
            SectionHeader(
              title: 'Cases Near You',
              subtitle: 'Recent reported cases requiring support',
            ),
            ...provider.cases.take(3).map((animalCase) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: AppColors.softShadow,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CaseDetailScreen(animalCase: animalCase),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      PawCareImage(
                        imageUrl: animalCase.imageUrl,
                        width: 80,
                        height: 80,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  animalCase.id,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                                StatusBadge(status: animalCase.status),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${animalCase.animalType} • ${animalCase.condition}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            // Make a Difference Donation Banner
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 24),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.orangeContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.orangeLight.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.favorite, color: AppColors.actionOrange, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Make a Difference',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.actionOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Help fund verified animal treatment cases. AnimalConnect transparently allocates 100% of donor support to verified medical care.',
                    style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  PawCareButton(
                    text: 'Donate Now to Support Cases',
                    type: PawCareButtonType.orange,
                    onPressed: () {
                      final req = provider.fundingRequests.first;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TreatmentFundingScreen(fundingRequest: req),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: color),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationPicker(BuildContext context, PawCareProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final cities = ['Coimbatore, TN', 'Tiruppur, TN', 'Chennai, TN', 'Erode, TN', 'Salem, TN', 'Bengaluru, KA'];
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Current Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...cities.map(
                (city) => ListTile(
                  leading: const Icon(Icons.location_city, color: AppColors.primaryBlue),
                  title: Text(city),
                  trailing: provider.currentLocation == city
                      ? const Icon(Icons.check_circle, color: AppColors.primaryBlue)
                      : null,
                  onTap: () {
                    provider.updateLocation(city);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

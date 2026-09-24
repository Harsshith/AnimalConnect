import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pawcare_provider.dart';
import '../../theme/app_colors.dart';
import '../cases/cases_tab.dart';
import '../donations/donations_tab.dart';
import '../adoption/adoption_screen.dart';
import '../notifications/notifications_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'volunteer_profile_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PawCareProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Volunteer Profile',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              provider.isAdminDemoMode ? Icons.admin_panel_settings : Icons.shield_outlined,
              color: provider.isAdminDemoMode ? AppColors.actionOrange : AppColors.textPrimary,
            ),
            tooltip: 'Toggle Admin Mode',
            onPressed: () {
              provider.toggleAdminDemoMode();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    provider.isAdminDemoMode
                        ? 'Demo Admin Mode Enabled!'
                        : 'Switched to Volunteer View.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppColors.softShadow,
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(Icons.person, size: 40, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.userName,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          provider.userPhone,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: provider.isVolunteer ? AppColors.greenContainer : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.stars,
                                size: 14,
                                color: provider.isVolunteer ? AppColors.secondary : AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                provider.isVolunteer ? 'Active Volunteer' : 'Member',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: provider.isVolunteer ? AppColors.secondary : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Lifetime Stats Row
            Row(
              children: [
                _buildStatBox('Cases', '${provider.cases.length}', AppColors.actionOrange),
                _buildStatBox('Helped', '${provider.totalAnimalsHelped}', AppColors.secondary),
                _buildStatBox('Donations', '${provider.donations.length}', AppColors.primaryBlue),
                _buildStatBox('Adoptions', '${provider.adoptionApplications.length}', Colors.purple.shade600),
              ],
            ),
            const SizedBox(height: 20),

            // Menu Items Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.volunteer_activism,
                    title: 'Become a Volunteer Settings',
                    color: AppColors.actionOrange,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const VolunteerProfileScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.assignment_outlined,
                    title: 'My Reported Cases',
                    color: AppColors.primaryBlue,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CasesTab()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.favorite_outline,
                    title: 'My Donations & Receipts',
                    color: AppColors.secondary,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DonationsTab()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.pets,
                    title: 'My Adoption Applications',
                    color: Colors.purple.shade600,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AdoptionScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notifications Center',
                    color: Colors.amber.shade700,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),
                  if (provider.isAdminDemoMode) ...[
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: Icons.admin_panel_settings,
                      title: 'Demo Admin Verification Dashboard',
                      color: AppColors.actionOrange,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                        );
                      },
                    ),
                  ],
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    color: AppColors.textPrimary,
                    onTap: () {
                      _showHelpModal(context);
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    color: AppColors.danger,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Frontend Demo Mode: Logged out.')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
    );
  }

  void _showHelpModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AnimalConnect Support & Guidelines'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AnimalConnect Helpline:'),
            SizedBox(height: 4),
            Text('+91 1800 123 PAW (729)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            SizedBox(height: 12),
            Text('For emergency animal rescue, select 24/7 verified hospitals on the report flow.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

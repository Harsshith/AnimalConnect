import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pawcare_provider.dart';
import '../../models/facility.dart';
import '../../theme/app_colors.dart';
import '../../widgets/pawcare_button.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PawCareProvider>(context);

    final unverifiedFacilities = provider.facilities.where((f) => !f.isVerified).toList();
    final pendingFunding = provider.fundingRequests.where((r) => !r.isApproved).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Verification Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Exit Admin Mode',
            onPressed: () {
              provider.toggleAdminDemoMode();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Overview Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryBlue],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings, color: AppColors.actionOrange, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AnimalConnect Admin Control',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Review and verify hospital certifications, clinic registrations & treatment funding requests.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Metrics Summary Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _buildMetricBox('Total Registered', '${provider.facilities.length}', Icons.business, AppColors.primaryBlue),
                _buildMetricBox('Pending Verification', '${unverifiedFacilities.length}', Icons.pending_actions, AppColors.actionOrange),
                _buildMetricBox('Active Funding', '${provider.fundingRequests.length}', Icons.volunteer_activism, AppColors.secondary),
                _buildMetricBox('Active Cases', '${provider.activeCases.length}', Icons.assignment, Colors.purple.shade600),
              ],
            ),
            const SizedBox(height: 20),

            // Pending Hospital & Facility Verification Requests
            Text(
              'Pending Facility Verification Requests',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (unverifiedFacilities.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.greenAccent),
                    SizedBox(width: 10),
                    Text('All registered facilities are currently verified!'),
                  ],
                ),
              )
            else
              ...unverifiedFacilities.map((fac) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fac.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.orangeContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Pending Verification', style: TextStyle(fontSize: 10, color: AppColors.actionOrange, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${fac.type.displayName} • ${fac.city} (${fac.address})'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: PawCareButton(
                              text: 'Approve',
                              type: PawCareButtonType.secondary,
                              onPressed: () {
                                provider.verifyFacility(fac.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${fac.name} has been VERIFIED! Badge awarded.')),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: PawCareButton(
                              text: 'Reject',
                              type: PawCareButtonType.outline,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Registration rejected. Change requested.')),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            const SizedBox(height: 20),

            // Funding Requests Audit
            Text(
              'Treatment Funding Requests Review',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...provider.fundingRequests.map((req) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(req.caseId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                        Text('Estimated: â‚¹${req.estimatedCost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.actionOrange)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${req.animalName} at ${req.hospitalName}'),
                    const SizedBox(height: 4),
                    Text('Diagnosis: ${req.diagnosis}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: PawCareButton(
                            text: 'Approve Support',
                            type: PawCareButtonType.primary,
                            onPressed: () {
                              provider.approveFunding(req.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Funding request ${req.id} approved!')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(val, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

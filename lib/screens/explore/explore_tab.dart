import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../facilities/facility_list_screen.dart';
import '../pet_care/pet_care_screen.dart';
import '../medicine/medicine_delivery_screen.dart';
import '../adoption/adoption_screen.dart';
import '../welfare_program/welfare_program_screen.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Explore AnimalConnect Ecosystem',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search hospitals, shelters, clinics, medicine...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune, color: AppColors.primaryBlue),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FacilityListScreen(initialFilter: 'All'),
                      ),
                    );
                  },
                ),
              ),
              onSubmitted: (query) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FacilityListScreen(initialFilter: 'All'),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Categories Grid Section
            Text(
              'Categories',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildCategoryCard(
                  context,
                  title: 'Veterinary Hospitals',
                  subtitle: '24/7 Trauma Emergency',
                  icon: Icons.local_hospital,
                  color: AppColors.primaryBlue,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FacilityListScreen(initialFilter: 'Hospital'),
                      ),
                    );
                  },
                ),
                _buildCategoryCard(
                  context,
                  title: 'Pet Clinics',
                  subtitle: 'Diagnostics & Care',
                  icon: Icons.medical_services,
                  color: AppColors.secondary,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FacilityListScreen(initialFilter: 'Clinic'),
                      ),
                    );
                  },
                ),
                _buildCategoryCard(
                  context,
                  title: 'Animal Shelters',
                  subtitle: 'Sanctuary & Foster',
                  icon: Icons.home_work,
                  color: Colors.purple.shade600,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FacilityListScreen(initialFilter: 'Shelter'),
                      ),
                    );
                  },
                ),
                _buildCategoryCard(
                  context,
                  title: 'Medicine Delivery',
                  subtitle: 'Prescription & Wound Care',
                  icon: Icons.local_pharmacy,
                  color: AppColors.actionOrange,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MedicineDeliveryScreen()),
                    );
                  },
                ),
                _buildCategoryCard(
                  context,
                  title: 'Pet Care & Boarding',
                  subtitle: 'Boarding, Grooming, Walk',
                  icon: Icons.pets,
                  color: Colors.indigo.shade600,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PetCareScreen()),
                    );
                  },
                ),
                _buildCategoryCard(
                  context,
                  title: 'Adoption Marketplace',
                  subtitle: 'Adopt Rescued Animals',
                  icon: Icons.favorite,
                  color: Colors.pink.shade600,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdoptionScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Welfare Program Banner
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WelfareProgramScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance, color: AppColors.primaryBlue, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Animal Welfare Programs',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryBlue),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Collaborating with authorized local government programs and registered partner bodies.',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.primaryBlue),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

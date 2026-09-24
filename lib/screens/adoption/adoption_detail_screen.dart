import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/adoption.dart';
import '../../services/pawcare_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/pawcare_image.dart';
import '../../widgets/pawcare_button.dart';

class AdoptionDetailScreen extends StatelessWidget {
  final AdoptionAnimal animal;

  const AdoptionDetailScreen({super.key, required this.animal});

  void _showAdoptionForm(BuildContext context) {
    final provider = Provider.of<PawCareProvider>(context, listen: false);
    final nameController = TextEditingController(text: provider.userName);
    final phoneController = TextEditingController(text: provider.userPhone);
    final livingController = TextEditingController(text: 'Own 3BHK Apartment with balcony & pet-friendly garden.');
    final experienceController = TextEditingController(text: '5 years experience caring for Indie dogs.');
    final reasonController = TextEditingController(text: 'Looking to give ${animal.name} a permanent loving home.');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Apply to Adopt ${animal.name}',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                const Text('Applicant Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.person, color: AppColors.primaryBlue)),
                ),
                const SizedBox(height: 12),

                const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.phone, color: AppColors.primaryBlue)),
                ),
                const SizedBox(height: 12),

                const Text('Living Situation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                TextField(
                  controller: livingController,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'e.g. Own house / Apartment, yard space...'),
                ),
                const SizedBox(height: 12),

                const Text('Pet Care Experience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                TextField(
                  controller: experienceController,
                  decoration: const InputDecoration(hintText: 'Previous pets owned or foster experience'),
                ),
                const SizedBox(height: 12),

                const Text('Reason for Adoption', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                TextField(
                  controller: reasonController,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),

                PawCareButton(
                  text: 'Submit Adoption Application',
                  type: PawCareButtonType.orange,
                  onPressed: () {
                    Navigator.pop(context);
                    final app = provider.submitAdoptionApplication(
                      animalId: animal.id,
                      animalName: animal.name,
                      livingSituation: livingController.text,
                      petExperience: experienceController.text,
                      reason: reasonController.text,
                    );

                    _showApplicationSubmittedDialog(context, app);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showApplicationSubmittedDialog(BuildContext context, AdoptionApplication app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text('Application Submitted', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Application ID: ${app.applicationId}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            const SizedBox(height: 8),
            Text('Shelter ${animal.shelterName} will review your application and contact you within 24-48 hours.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Cover Image App Bar
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: PawCareImage(
                imageUrl: animal.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.name,
                          style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${animal.breed} â€¢ ${animal.age}',
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        animal.gender,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Health Badges
                Row(
                  children: [
                    _buildTag(
                      animal.isVaccinated ? 'Fully Vaccinated' : 'Vaccine Pending',
                      animal.isVaccinated ? AppColors.greenAccent : AppColors.actionOrange,
                      animal.isVaccinated ? Icons.shield : Icons.warning_amber,
                    ),
                    const SizedBox(width: 8),
                    _buildTag(
                      animal.isSterilized ? 'Sterilized' : 'Not Sterilized',
                      animal.isSterilized ? AppColors.secondary : AppColors.textMuted,
                      animal.isSterilized ? Icons.verified : Icons.info,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Personality Tags
                const Text('Personality', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: animal.personality.map((p) {
                    return Chip(
                      label: Text(p),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.cardBorder),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Story & Health
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
                      const Text('About & Story', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 6),
                      Text(animal.story, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4)),
                      const Divider(height: 20),
                      const Text('Health Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 6),
                      Text(animal.healthSummary, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Shelter Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        child: Icon(Icons.home_work, color: AppColors.primaryBlue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(animal.shelterName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 4),
                                const VerifiedBadge(showText: false),
                              ],
                            ),
                            Text(animal.location, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                PawCareButton(
                  text: 'Apply for Adoption',
                  type: PawCareButtonType.orange,
                  icon: Icons.favorite,
                  onPressed: () => _showAdoptionForm(context),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

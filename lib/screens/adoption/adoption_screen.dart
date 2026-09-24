import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/adoption.dart';
import '../../services/pawcare_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/pawcare_image.dart';
import '../../widgets/pawcare_button.dart';
import 'adoption_detail_screen.dart';

class AdoptionScreen extends StatelessWidget {
  const AdoptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PawCareProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Animal Adoption Marketplace',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primaryBlue,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: 'Dogs'),
              Tab(text: 'Cats'),
              Tab(text: 'Other'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAnimalGrid(context, provider.adoptionAnimals.where((a) => a.animalType == 'Dog').toList()),
            _buildAnimalGrid(context, provider.adoptionAnimals.where((a) => a.animalType == 'Cat').toList()),
            _buildAnimalGrid(context, provider.adoptionAnimals.where((a) => a.animalType == 'Other').toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalGrid(BuildContext context, List<AdoptionAnimal> animals) {
    if (animals.isEmpty) {
      return const Center(
        child: Text('No animals available for adoption in this category.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: animals.length,
      itemBuilder: (context, index) {
        final animal = animals[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  PawCareImage(
                    imageUrl: animal.imageUrl,
                    height: 180,
                    width: double.infinity,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        animal.gender,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          animal.name,
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          animal.age,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${animal.breed} â€¢ ${animal.location}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (animal.isVaccinated)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: AppColors.greenContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Vaccinated', style: TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                          ),
                        if (animal.isSterilized)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Sterilized', style: TextStyle(fontSize: 10, color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                          ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              animal.shelterName,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 4),
                            const VerifiedBadge(showText: false),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    PawCareButton(
                      text: 'View Profile & Apply',
                      type: PawCareButtonType.outline,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AdoptionDetailScreen(animal: animal),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

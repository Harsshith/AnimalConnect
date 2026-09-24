import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pet_care.dart';
import '../../services/pawcare_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/pawcare_image.dart';
import '../../widgets/pawcare_button.dart';

class PetCareScreen extends StatefulWidget {
  const PetCareScreen({super.key});

  @override
  State<PetCareScreen> createState() => _PetCareScreenState();
}

class _PetCareScreenState extends State<PetCareScreen> {
  String _selectedService = 'All';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PawCareProvider>(context);

    final filteredProviders = provider.petCareProviders.where((p) {
      if (_selectedService != 'All' && p.serviceType != _selectedService) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registered Pet Care Providers'),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Pet Boarding', 'Grooming', 'Foster Care', 'Pet Walking'].map((srv) {
                  final isSelected = _selectedService == srv;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(srv),
                      selected: isSelected,
                      selectedColor: AppColors.primaryBlue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedService = srv;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Provider Cards List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProviders.length,
              itemBuilder: (context, index) {
                final item = filteredProviders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
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
                        children: [
                          PawCareImage(
                            imageUrl: item.imageUrl,
                            width: 80,
                            height: 80,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (item.isVerified) const VerifiedBadge(showText: false),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.serviceType} â€¢ ${item.location}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 14, color: Colors.amber),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${item.rating}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: item.availabilityStatus == 'Available'
                                            ? AppColors.greenContainer
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.availabilityStatus,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: item.availabilityStatus == 'Available'
                                              ? AppColors.secondary
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.description,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Rate', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                              Text(
                                item.pricePerDay == 0
                                    ? 'Volunteer Free'
                                    : 'â‚¹${item.pricePerDay.toStringAsFixed(0)}/day',
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          PawCareButton(
                            text: 'Book Provider',
                            type: PawCareButtonType.outline,
                            fullWidth: false,
                            onPressed: () {
                              _showProviderModal(context, item);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showProviderModal(BuildContext context, PetCareProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider.name, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${provider.serviceType} â€¢ Verified Provider'),
            const SizedBox(height: 12),
            Text('Contact Phone: ${provider.phone}'),
            const SizedBox(height: 6),
            Text('Location: ${provider.location}'),
            const SizedBox(height: 16),
            PawCareButton(
              text: 'Call Provider (${provider.phone})',
              type: PawCareButtonType.primary,
              icon: Icons.phone,
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calling ${provider.phone}...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

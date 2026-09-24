import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pawcare_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/facility_card.dart';
import '../../models/facility.dart';
import 'facility_detail_screen.dart';
import 'facility_registration_screen.dart';

class FacilityListScreen extends StatefulWidget {
  final String initialFilter;

  const FacilityListScreen({super.key, this.initialFilter = 'All'});

  @override
  State<FacilityListScreen> createState() => _FacilityListScreenState();
}

class _FacilityListScreenState extends State<FacilityListScreen> {
  late String _currentFilter;
  final TextEditingController _searchController = TextEditingController();
  bool _emergencyOnly = false;
  bool _verifiedOnly = false;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PawCareProvider>(context);

    // Filter logic
    final filteredFacilities = provider.facilities.where((f) {
      if (_currentFilter == 'Hospital' && f.type != FacilityType.hospital) return false;
      if (_currentFilter == 'Clinic' && f.type != FacilityType.clinic) return false;
      if (_currentFilter == 'Shelter' && f.type != FacilityType.shelter) return false;

      if (_emergencyOnly && !f.hasEmergency) return false;
      if (_verifiedOnly && !f.isVerified) return false;

      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final nameMatch = f.name.toLowerCase().contains(query);
        final cityMatch = f.city.toLowerCase().contains(query);
        final serviceMatch = f.services.any((s) => s.toLowerCase().contains(query));
        return nameMatch || cityMatch || serviceMatch;
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _currentFilter == 'All' ? 'Verified Animal Facilities' : '$_currentFilter List',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_outlined),
            tooltip: 'Register New Facility',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FacilityRegistrationScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search hospital, clinic, shelter or service...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),

            // Filter Chips Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...['All', 'Hospital', 'Clinic', 'Shelter'].map((filter) {
                    final isSelected = _currentFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        selectedColor: AppColors.primaryBlue,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _currentFilter = filter;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                  FilterChip(
                    label: const Text('24/7 Emergency'),
                    selected: _emergencyOnly,
                    selectedColor: AppColors.orangeContainer,
                    checkmarkColor: AppColors.actionOrange,
                    labelStyle: TextStyle(
                      color: _emergencyOnly ? AppColors.actionOrange : AppColors.textPrimary,
                      fontWeight: _emergencyOnly ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _emergencyOnly = selected;
                      });
                    },
                  ),
                  const SizedBox(width: 6),
                  FilterChip(
                    label: const Text('Verified Only'),
                    selected: _verifiedOnly,
                    selectedColor: AppColors.primaryContainer,
                    checkmarkColor: AppColors.primaryBlue,
                    labelStyle: TextStyle(
                      color: _verifiedOnly ? AppColors.primaryBlue : AppColors.textPrimary,
                      fontWeight: _verifiedOnly ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _verifiedOnly = selected;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Results count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredFacilities.length} facilities available',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                Text(
                  'Location: ${provider.currentLocation}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Facilities List View
            Expanded(
              child: filteredFacilities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_hospital_outlined, size: 54, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No facilities match filter',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text('Try adjusting search query or clearing filter chips.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredFacilities.length,
                      itemBuilder: (context, index) {
                        final fac = filteredFacilities[index];
                        return FacilityCard(
                          facility: fac,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FacilityDetailScreen(facility: fac),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

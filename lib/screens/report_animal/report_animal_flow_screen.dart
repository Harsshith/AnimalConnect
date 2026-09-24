import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/pawcare_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/pawcare_button.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/pawcare_image.dart';
import '../../models/facility.dart';
import 'case_success_screen.dart';

class ReportAnimalFlowScreen extends StatefulWidget {
  const ReportAnimalFlowScreen({super.key});

  @override
  State<ReportAnimalFlowScreen> createState() => _ReportAnimalFlowScreenState();
}

class _ReportAnimalFlowScreenState extends State<ReportAnimalFlowScreen> {
  int _currentStep = 0;

  // Step 1: Photo
  String _selectedImageUrl = 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80';
  bool _hasCustomPhoto = true;

  // Step 2: Details
  String _animalType = 'Dog';
  String _condition = 'Injured';
  String _ageGroup = 'Adult';
  final TextEditingController _descriptionController = TextEditingController(
    text: 'Found Indie animal with leg injury near signal. Needs immediate medical triage.',
  );

  // Step 3: Location
  final TextEditingController _addressController = TextEditingController(
    text: '142 Avinashi Road, Peelamedu, Coimbatore',
  );
  final TextEditingController _landmarkController = TextEditingController(
    text: 'Near PSG Tech Gate 2',
  );

  // Step 4: Volunteer Action
  String _volunteerAction = 'I can take the animal to a facility';

  // Step 5: Facility Selection
  Facility? _selectedFacility;

  @override
  void initState() {
    super.initState();
    // Default facility selection to first hospital
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PawCareProvider>(context, listen: false);
      if (provider.hospitalsAndClinics.isNotEmpty) {
        setState(() {
          _selectedFacility = provider.hospitalsAndClinics.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _submitReport() {
    final provider = Provider.of<PawCareProvider>(context, listen: false);
    final newCase = provider.createNewCase(
      animalType: _animalType,
      condition: _condition,
      description: _descriptionController.text,
      ageGroup: _ageGroup,
      locationAddress: _addressController.text,
      landmark: _landmarkController.text,
      volunteerAction: _volunteerAction,
      selectedFacilityId: _selectedFacility?.id ?? 'fac-01',
      selectedFacilityName: _selectedFacility?.name ?? 'Paws Veterinary Specialty Hospital',
      imageUrl: _selectedImageUrl,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CaseSuccessScreen(createdCase: newCase),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PawCareProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Report an Animal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Step Progress Bar Indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: List.generate(6, (index) {
                final isPassed = index <= _currentStep;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isPassed ? AppColors.actionOrange : AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Main Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStepContent(provider),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0) ...[
                  Expanded(
                    child: PawCareButton(
                      text: 'Back',
                      type: PawCareButtonType.outline,
                      onPressed: _previousStep,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: PawCareButton(
                    text: _currentStep == 5 ? 'Submit Case' : 'Next Step',
                    type: _currentStep == 5
                        ? PawCareButtonType.orange
                        : PawCareButtonType.primary,
                    onPressed: _currentStep == 5 ? _submitReport : _nextStep,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent(PawCareProvider provider) {
    switch (_currentStep) {
      case 0:
        return _buildStep1Photo();
      case 1:
        return _buildStep2Details();
      case 2:
        return _buildStep3Location();
      case 3:
        return _buildStep4VolunteerAction();
      case 4:
        return _buildStep5Facilities(provider);
      case 5:
        return _buildStep6Review();
      default:
        return Container();
    }
  }

  // STEP 1: Animal Photo
  Widget _buildStep1Photo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 1 — Animal Photo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Add a clear photo of the animal to help veterinary triage.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        // Image Upload Area
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder, width: 1.5),
          ),
          child: _hasCustomPhoto
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    PawCareImage(
                      imageUrl: _selectedImageUrl,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 14),
                            SizedBox(width: 4),
                            Text('Photo Selected', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 48, color: AppColors.textMuted),
                      SizedBox(height: 8),
                      Text('No photo selected yet', style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: PawCareButton(
                text: 'Take Photo',
                icon: Icons.camera_alt,
                type: PawCareButtonType.outline,
                onPressed: () {
                  setState(() {
                    _hasCustomPhoto = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera photo captured for demo.')),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PawCareButton(
                text: 'Gallery',
                icon: Icons.photo_library,
                type: PawCareButtonType.outline,
                onPressed: () {
                  setState(() {
                    _hasCustomPhoto = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gallery photo selected for demo.')),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PawCareButton(
          text: 'Use Demo Photo (Injured Dog)',
          icon: Icons.auto_awesome,
          type: PawCareButtonType.secondary,
          onPressed: () {
            setState(() {
              _selectedImageUrl = 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80';
              _hasCustomPhoto = true;
            });
          },
        ),
      ],
    );
  }

  // STEP 2: Animal Details
  Widget _buildStep2Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 2 — Animal Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Specify the animal type, condition, and observed symptoms.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),

        // Animal Type Selector
        const Text('Animal Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: ['Dog', 'Cat', 'Other'].map((type) {
            final isSelected = _animalType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _animalType = type;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryContainer : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryBlue : AppColors.cardBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      type,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Condition Chips
        const Text('Condition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Critical', 'Injured', 'Sick', 'Healthy', 'Abandoned', 'Puppy/Kitten'].map((cond) {
            final isSelected = _condition == cond;
            return ChoiceChip(
              label: Text(cond),
              selected: isSelected,
              selectedColor: AppColors.orangeContainer,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.actionOrange : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _condition = cond;
                  });
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Age Group Selector
        const Text('Approximate Age', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['Young', 'Adult', 'Senior', 'Unknown'].map((age) {
            final isSelected = _ageGroup == age;
            return ChoiceChip(
              label: Text(age),
              selected: isSelected,
              selectedColor: AppColors.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _ageGroup = age;
                  });
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Description Input
        const Text('Description / Observed Symptoms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Describe injury, behavior, or immediate hazards...',
          ),
        ),
      ],
    );
  }

  // STEP 3: Location
  Widget _buildStep3Location() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 3 — Location Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pinpoint where the animal was spotted.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // Map visual mockup
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 48, color: AppColors.textMuted),
                  SizedBox(height: 4),
                  Text('GPS Map Mockup (Coimbatore, TN)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.actionOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        PawCareButton(
          text: 'Use Current Location',
          icon: Icons.my_location,
          type: PawCareButtonType.outline,
          onPressed: () {
            setState(() {
              _addressController.text = '142 Avinashi Road, Peelamedu, Coimbatore';
              _landmarkController.text = 'Near PSG Tech Gate 2';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location auto-filled to current GPS position.')),
            );
          },
        ),
        const SizedBox(height: 16),

        const Text('Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          controller: _addressController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.location_city, color: AppColors.primaryBlue),
          ),
        ),
        const SizedBox(height: 14),

        const Text('Landmark', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          controller: _landmarkController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.store, color: AppColors.primaryBlue),
          ),
        ),
      ],
    );
  }

  // STEP 4: Volunteer Action
  Widget _buildStep4VolunteerAction() {
    final options = [
      'I can take the animal to a facility',
      'I need help finding a facility',
      'I can temporarily care for the animal',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 4 — Volunteer Action',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'What role can you play for this animal?',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),

        ...options.map((opt) {
          final isSelected = _volunteerAction == opt;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryContainer : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : AppColors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ListTile(
              onTap: () {
                setState(() {
                  _volunteerAction = opt;
                });
              },
              leading: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primaryBlue : AppColors.textMuted,
              ),
              title: Text(
                opt,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // STEP 5: Nearby Verified Facilities
  Widget _buildStep5Facilities(PawCareProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 5 — Select Verified Facility',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Choose a verified veterinary hospital or clinic for treatment.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        ...provider.hospitalsAndClinics.map((fac) {
          final isSelected = _selectedFacility?.id == fac.id;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.greenContainer : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.secondary : AppColors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                PawCareImage(
                  imageUrl: fac.imageUrl,
                  width: 70,
                  height: 70,
                  borderRadius: BorderRadius.circular(12),
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
                              fac.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const VerifiedBadge(showText: false),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${fac.distanceKm} km • ${fac.openHours}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        fac.hasEmergency ? '24/7 Emergency Available' : 'Standard Clinic Care',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: fac.hasEmergency ? AppColors.actionOrange : AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: fac.id,
                  groupValue: _selectedFacility?.id,
                  activeColor: AppColors.secondary,
                  onChanged: (val) {
                    setState(() {
                      _selectedFacility = fac;
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // STEP 6: Review & Submit
  Widget _buildStep6Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 6 — Review & Submit',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Verify all report details before final submission.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),

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
              PawCareImage(
                imageUrl: _selectedImageUrl,
                height: 160,
                width: double.infinity,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(height: 16),
              _buildReviewRow('Animal Type', _animalType),
              _buildReviewRow('Condition', _condition),
              _buildReviewRow('Approx. Age', _ageGroup),
              _buildReviewRow('Description', _descriptionController.text),
              _buildReviewRow('Location', '${_addressController.text} (${_landmarkController.text})'),
              _buildReviewRow('Volunteer Action', _volunteerAction),
              _buildReviewRow('Selected Facility', _selectedFacility?.name ?? 'Paws Hospital'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

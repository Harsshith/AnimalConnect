import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/facility.dart';
import '../../services/pawcare_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/pawcare_button.dart';

class FacilityRegistrationScreen extends StatefulWidget {
  const FacilityRegistrationScreen({super.key});

  @override
  State<FacilityRegistrationScreen> createState() => _FacilityRegistrationScreenState();
}

class _FacilityRegistrationScreenState extends State<FacilityRegistrationScreen> {
  FacilityType _selectedType = FacilityType.hospital;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(text: 'Coimbatore');
  final TextEditingController _servicesController = TextEditingController();

  bool _hasEmergency = true;
  bool _offersSupportedCare = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _servicesController.dispose();
    super.dispose();
  }

  void _submitRegistration() {
    if (_nameController.text.trim().isEmpty || _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out facility name and address.')),
      );
      return;
    }

    final provider = Provider.of<PawCareProvider>(context, listen: false);

    final newFacility = Facility(
      id: 'fac-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      type: _selectedType,
      isVerified: false, // Explicitly false until Admin Approval
      imageUrl: 'https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&w=800&q=80',
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      distanceKm: 2.0,
      phone: _phoneController.text.trim().isEmpty ? '+91 98765 00099' : _phoneController.text.trim(),
      rating: 5.0,
      openHours: '09:00 AM - 08:00 PM',
      isOpenNow: true,
      hasEmergency: _hasEmergency,
      offersSupportedCare: _offersSupportedCare,
      services: _servicesController.text.isEmpty
          ? ['General Triage', 'Emergency Care', 'Vaccination']
          : _servicesController.text.split(',').map((s) => s.trim()).toList(),
      totalAnimalsHelped: 0,
    );

    provider.registerFacility(newFacility);

    showDialog(
      context: context,
      barrierDismissible: false,
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
            Text(
              'Your facility registration application has been submitted for AnimalConnect Verification Review.',
              style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Text(
                'Status: Pending AnimalConnect Verification Review. Once verified, your facility badge will appear live on the care network.',
                style: TextStyle(fontSize: 11, color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Dialog
              Navigator.pop(context); // Screen
            },
            child: const Text('OK, Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Register Facility'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notice Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user, color: AppColors.primaryBlue, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Verification Required: All registered hospitals, clinics, and shelters must pass AnimalConnect verification before receiving active cases.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Select Facility Type
            const Text('Facility Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            DropdownButtonFormField<FacilityType>(
              value: _selectedType,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category, color: AppColors.primaryBlue),
              ),
              items: FacilityType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedType = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Form Fields
            const Text('Facility Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Hope Veterinary Specialty Clinic',
                prefixIcon: Icon(Icons.business, color: AppColors.primaryBlue),
              ),
            ),
            const SizedBox(height: 14),

            const Text('Contact Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '+91 98765 43210',
                prefixIcon: Icon(Icons.phone, color: AppColors.primaryBlue),
              ),
            ),
            const SizedBox(height: 14),

            const Text('Street Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                hintText: 'Door No, Street Name, Landmark',
                prefixIcon: Icon(Icons.location_on, color: AppColors.primaryBlue),
              ),
            ),
            const SizedBox(height: 14),

            const Text('City / Region', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                hintText: 'Coimbatore',
                prefixIcon: Icon(Icons.location_city, color: AppColors.primaryBlue),
              ),
            ),
            const SizedBox(height: 14),

            const Text('Offered Services (Comma separated)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _servicesController,
              decoration: const InputDecoration(
                hintText: 'e.g. Emergency Care, Surgery, X-Ray, ICU Unit',
                prefixIcon: Icon(Icons.medical_services, color: AppColors.primaryBlue),
              ),
            ),
            const SizedBox(height: 16),

            // Switches
            SwitchListTile(
              title: const Text('24/7 Emergency Trauma Service', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: const Text('Facility available for night emergency rescues'),
              value: _hasEmergency,
              activeColor: AppColors.actionOrange,
              onChanged: (val) {
                setState(() {
                  _hasEmergency = val;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Accept AnimalConnect Treatment Support Cases', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: const Text('Willing to treat verified fund-allocated stray cases'),
              value: _offersSupportedCare,
              activeColor: AppColors.secondary,
              onChanged: (val) {
                setState(() {
                  _offersSupportedCare = val;
                });
              },
            ),
            const SizedBox(height: 24),

            PawCareButton(
              text: 'Submit Application for Verification',
              type: PawCareButtonType.primary,
              icon: Icons.send,
              onPressed: _submitRegistration,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

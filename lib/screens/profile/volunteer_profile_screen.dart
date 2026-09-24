import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pawcare_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/pawcare_button.dart';

class VolunteerProfileScreen extends StatefulWidget {
  const VolunteerProfileScreen({super.key});

  @override
  State<VolunteerProfileScreen> createState() => _VolunteerProfileScreenState();
}

class _VolunteerProfileScreenState extends State<VolunteerProfileScreen> {
  final List<String> _allCapabilities = [
    'I can transport animals',
    'I can provide temporary care',
    'I can help with medicine pickup',
    'I can support adoption',
    'I can donate',
  ];

  late List<String> _selectedCapabilities;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PawCareProvider>(context, listen: false);
    _selectedCapabilities = List.from(provider.volunteerCapabilities);
  }

  void _saveSettings() {
    final provider = Provider.of<PawCareProvider>(context, listen: false);
    provider.updateVolunteerCapabilities(_selectedCapabilities);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Volunteer capabilities updated successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PawCareProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Volunteer Profile & Skills'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enable Volunteer Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppColors.softShadow,
              ),
              child: SwitchListTile(
                title: Text(
                  'Become a Verified Volunteer',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Receive notifications when animals need transport or care nearby.'),
                value: provider.isVolunteer,
                activeColor: AppColors.actionOrange,
                onChanged: (val) {
                  provider.toggleVolunteerStatus(val);
                },
              ),
            ),
            const SizedBox(height: 20),

            // Capabilities Checklist (Requirement #17)
            Text(
              'What can you do as a Volunteer?',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ..._allCapabilities.map((cap) {
              final isChecked = _selectedCapabilities.contains(cap);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isChecked ? AppColors.orangeContainer : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isChecked ? AppColors.actionOrange : AppColors.cardBorder,
                  ),
                ),
                child: CheckboxListTile(
                  title: Text(
                    cap,
                    style: TextStyle(
                      fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  value: isChecked,
                  activeColor: AppColors.actionOrange,
                  onChanged: provider.isVolunteer
                      ? (val) {
                          setState(() {
                            if (val == true) {
                              _selectedCapabilities.add(cap);
                            } else {
                              _selectedCapabilities.remove(cap);
                            }
                          });
                        }
                      : null,
                ),
              );
            }).toList(),
            const SizedBox(height: 20),

            // Activity History
            Text(
              'Volunteer Activity History',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildActivityItem('Case PC-2026-00124', 'Transported Indie dog Bruno to Paws Hospital', '4 hrs ago'),
            _buildActivityItem('Case PC-2026-00121', 'Provided temporary care for 3 abandoned puppies', '3 days ago'),
            _buildActivityItem('Medicine Order PC-MED-9941', 'Picked up antiseptic spray from pharmacy', '1 day ago'),
            const SizedBox(height: 24),

            PawCareButton(
              text: 'Save Volunteer Settings',
              type: PawCareButtonType.orange,
              onPressed: _saveSettings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String desc, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.secondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

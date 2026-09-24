import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/funding_request.dart';
import '../../services/pawcare_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/pawcare_image.dart';
import '../../widgets/pawcare_button.dart';
import '../donations/donation_receipt_screen.dart';

class TreatmentFundingScreen extends StatefulWidget {
  final FundingRequest fundingRequest;

  const TreatmentFundingScreen({super.key, required this.fundingRequest});

  @override
  State<TreatmentFundingScreen> createState() => _TreatmentFundingScreenState();
}

class _TreatmentFundingScreenState extends State<TreatmentFundingScreen> {
  double _selectedAmount = 250.0;
  final TextEditingController _customAmountController = TextEditingController();

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _showDonateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Support Treatment Case',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Text(
                    'Supporting ${widget.fundingRequest.animalName} (${widget.fundingRequest.caseId})',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Donation Amount (â‚¹)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: [100.0, 250.0, 500.0, 1000.0].map((amt) {
                      final isSelected = _selectedAmount == amt;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _selectedAmount = amt;
                              _customAmountController.clear();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.orangeContainer : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.actionOrange : AppColors.cardBorder,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'â‚¹${amt.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.actionOrange : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _customAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter custom amount in â‚¹',
                      prefixIcon: Icon(Icons.currency_rupee, color: AppColors.actionOrange),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null && parsed > 0) {
                        setModalState(() {
                          _selectedAmount = parsed;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  PawCareButton(
                    text: 'Confirm Donation â‚¹${_selectedAmount.toStringAsFixed(0)}',
                    type: PawCareButtonType.orange,
                    onPressed: () {
                      Navigator.pop(context);
                      final provider = Provider.of<PawCareProvider>(context, listen: false);
                      final donation = provider.recordDonation(
                        caseId: widget.fundingRequest.caseId,
                        caseTitle: widget.fundingRequest.animalName,
                        amount: _selectedAmount,
                        category: 'Emergency Treatment',
                      );

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DonationReceiptScreen(donation: donation),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.fundingRequest;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Treatment Support'),
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_user_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification Certificate: AnimalConnect Protocol Compliant')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Explanation Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield, color: AppColors.primaryBlue, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AnimalConnect may provide financial support for eligible verified treatment cases.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Case & Animal Overview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PawCareImage(
                        imageUrl: req.animalImageUrl,
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
                                Text(
                                  req.caseId,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const VerifiedBadge(showText: true),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              req.animalName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              req.hospitalName,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildDetailItem('Diagnosis', req.diagnosis),
                  _buildDetailItem('Treatment Required', req.treatmentDetails),
                  _buildDetailItem('Assigned Volunteer', '${req.volunteerName} (Active Volunteer)'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Verification Checklist Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'AnimalConnect Verification Checklist',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildChecklistItem('Volunteer identity verified', req.checklist.volunteerVerified),
                  _buildChecklistItem('Partner hospital verified & registered', req.checklist.hospitalVerified),
                  _buildChecklistItem('Animal photo & triage match confirmed', req.checklist.photosMatched),
                  _buildChecklistItem('Itemized treatment estimate submitted', req.checklist.treatmentSubmitted),
                  _buildChecklistItem('Medical evidence & lab reports verified', req.checklist.medicalEvidenceSubmitted),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Funding Breakdown Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Funding Breakdown',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildCostRow('Estimated Treatment Cost', '₹${req.estimatedCost.toStringAsFixed(0)}', isBold: true),
                  const Divider(height: 18),
                  _buildCostRow('AnimalConnect Fund Allocation', '₹${req.pawcareSupport.toStringAsFixed(0)}', color: AppColors.primaryBlue),
                  _buildCostRow('Donor Community Support', '₹${req.donorSupport.toStringAsFixed(0)}', color: AppColors.secondary),
                  const Divider(height: 18),
                  _buildCostRow('Remaining Goal', '₹${req.remainingAmount.toStringAsFixed(0)}', color: AppColors.actionOrange, isBold: true),
                  const SizedBox(height: 16),
                  PawCareButton(
                    text: 'Support This Case',
                    type: PawCareButtonType.orange,
                    icon: Icons.favorite,
                    onPressed: () {
                      _showDonateModal(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SAFETY/REALISM DISCLAIMER BANNER (Mandatory Rule)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFB45309), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Funding is subject to case verification and available funds. AnimalConnect does not guarantee automatic free treatment for all cases.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                        height: 1.4,
                      ),
                    ),
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

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String label, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isChecked ? AppColors.greenAccent : AppColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isChecked ? AppColors.textPrimary : AppColors.textMuted,
                fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, String amount, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              color: color ?? AppColors.textPrimary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

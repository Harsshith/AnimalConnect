import 'package:flutter/material.dart';
import '../models/funding_request.dart';
import '../theme/app_colors.dart';
import 'pawcare_image.dart';
import 'pawcare_button.dart';

class DonationCard extends StatelessWidget {
  final FundingRequest request;
  final VoidCallback onDonate;

  const DonationCard({
    super.key,
    required this.request,
    required this.onDonate,
  });

  @override
  Widget build(BuildContext context) {
    final raised = request.pawcareSupport + request.donorSupport;
    final progress = (raised / request.estimatedCost).clamp(0.0, 1.0);

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
                imageUrl: request.animalImageUrl,
                width: 70,
                height: 70,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.orangeContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Verified Treatment Request',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.actionOrange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.animalName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.hospitalName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Diagnosis: ${request.diagnosis}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.primaryContainer,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Supported', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text(
                    '₹${raised.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Required', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text(
                    '₹${request.estimatedCost.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Remaining', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text(
                    '₹${request.remainingAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.actionOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          PawCareButton(
            text: 'Donate Now to Support Bruno',
            type: PawCareButtonType.orange,
            onPressed: onDonate,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/facility.dart';
import '../theme/app_colors.dart';
import 'verified_badge.dart';
import 'pawcare_image.dart';
import 'pawcare_button.dart';

class FacilityCard extends StatelessWidget {
  final Facility facility;
  final VoidCallback onTap;
  final VoidCallback? onSelectForCase;
  final bool compact;

  const FacilityCard({
    super.key,
    required this.facility,
    required this.onTap,
    this.onSelectForCase,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppColors.softShadow,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  PawCareImage(
                    imageUrl: facility.imageUrl,
                    height: 110,
                    width: double.infinity,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  if (facility.isVerified)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: VerifiedBadge(showText: false),
                    ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: facility.isOpenNow ? AppColors.success : AppColors.danger,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        facility.isOpenNow ? 'Open Now' : 'Closed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 2),
                        Text(
                          '${facility.distanceKm} km • ${facility.city}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PawCareImage(
                    imageUrl: facility.imageUrl,
                    width: 90,
                    height: 90,
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
                                facility.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (facility.isVerified) ...[
                              const SizedBox(width: 4),
                              const VerifiedBadge(showText: true),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${facility.type.displayName} • ${facility.city}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: facility.isOpenNow ? AppColors.greenContainer : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                facility.isOpenNow ? 'Open Now' : 'Closed',
                                style: TextStyle(
                                  color: facility.isOpenNow ? AppColors.success : AppColors.danger,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.near_me, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 2),
                            Text(
                              '${facility.distanceKm} km',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.star, size: 13, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              '${facility.rating}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Services badges
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (facility.hasEmergency)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.orangeContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_hospital, size: 12, color: AppColors.actionOrange),
                          SizedBox(width: 4),
                          Text(
                            '24/7 Emergency',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.actionOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (facility.offersSupportedCare)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'AnimalConnect Supported Fund',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PawCareButton(
                      text: 'View Details',
                      type: PawCareButtonType.outline,
                      onPressed: onTap,
                      fullWidth: true,
                    ),
                  ),
                  if (onSelectForCase != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: PawCareButton(
                        text: 'Select Facility',
                        type: PawCareButtonType.primary,
                        onPressed: onSelectForCase!,
                        fullWidth: true,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

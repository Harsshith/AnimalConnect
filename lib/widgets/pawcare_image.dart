import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PawCareImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;

  const PawCareImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.pets,
  });

  @override
  Widget build(BuildContext context) {
    final clipRadius = borderRadius ?? BorderRadius.zero;

    Widget placeholder() => Container(
          width: width,
          height: height,
          color: AppColors.primaryContainer,
          child: Center(
            child: Icon(
              fallbackIcon,
              color: AppColors.primaryBlue.withOpacity(0.5),
              size: (height != null && height! < 60) ? 24 : 36,
            ),
          ),
        );

    if (imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: clipRadius,
        child: placeholder(),
      );
    }

    return ClipRRect(
      borderRadius: clipRadius,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return placeholder();
        },
      ),
    );
  }
}

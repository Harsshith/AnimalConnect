import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum PawCareButtonType { primary, secondary, orange, outline }

class PawCareButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final PawCareButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const PawCareButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = PawCareButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case PawCareButtonType.primary:
        bg = AppColors.primaryBlue;
        fg = Colors.white;
        break;
      case PawCareButtonType.secondary:
        bg = AppColors.secondary;
        fg = Colors.white;
        break;
      case PawCareButtonType.orange:
        bg = AppColors.actionOrange;
        fg = Colors.white;
        break;
      case PawCareButtonType.outline:
        bg = Colors.transparent;
        fg = AppColors.primaryBlue;
        break;
    }

    Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]
      ],
    );

    if (type == PawCareButtonType.outline) {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
          child: content,
        ),
      );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        child: content,
      ),
    );
  }
}

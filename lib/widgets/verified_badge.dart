import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;
  final bool showText;
  final String label;

  const VerifiedBadge({
    super.key,
    this.size = 18,
    this.showText = true,
    this.label = 'Verified',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: showText
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
          : const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF93C5FD), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            color: const Color(0xFF1E3A8A),
            size: size,
          ),
          if (showText) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

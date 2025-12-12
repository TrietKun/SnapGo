import 'package:flutter/material.dart';

class ThumbnailItem extends StatelessWidget {
  final String imageUrl;
  final bool isActive;

  const ThumbnailItem({
    super.key,
    required this.imageUrl,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? Colors.white.withOpacity(0.8)
              : Colors.white.withOpacity(0.2),
          width: isActive ? 2.5 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: 120,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              width: 120,
              height: 100,
              color: Colors.grey.shade300,
              child: Icon(
                Icons.broken_image_rounded,
                color: Colors.grey.shade500,
                size: 32,
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

class BuildLocation extends StatelessWidget {
  final Animation<double> glowAnimation;
  final String name;
  final String district;
  final String city;

  const BuildLocation({
    super.key,
    required this.glowAnimation,
    required this.name,
    required this.district,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Glow icon
        AnimatedBuilder(
          animation: glowAnimation,
          builder: (_, child) {
            return Transform.scale(
              scale: 1.0 + (0.05 * math.sin(glowAnimation.value * math.pi)),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 10),

        // Text info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.3,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black38,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 2),

              // District + City
              Text(
                '$district, $city',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w500,
                  shadows: const [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black26,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

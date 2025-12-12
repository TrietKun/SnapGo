import 'dart:ui';
import 'package:flutter/material.dart';

class GlassSection extends StatelessWidget {
  final List<String> images;
  final List<String> loopImages;
  final Widget Function(int index) thumbnailBuilder;
  final ScrollController thumbController;
  final Widget locationInfo;

  static const double radius = 24;

  const GlassSection({
    super.key,
    required this.images,
    required this.loopImages,
    required this.thumbnailBuilder,
    required this.thumbController,
    required this.locationInfo,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(radius),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.4),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (images.length > 1) ...[
                SizedBox(
                  height: 100,
                  child: Stack(
                    children: [
                      // Thumbnails
                      ListView.separated(
                        controller: thumbController,
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: loopImages.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) =>
                            thumbnailBuilder(index),
                      ),

                      // Left fade
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: Container(
                            width: 32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Right fade
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: Container(
                            width: 32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Location info widget đưa từ ngoài vào
              locationInfo,
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:snapgo/widgets/spot_card_image/idicator_image.dart';

class MainImage extends StatelessWidget {
  final List<String> images;
  final PageController pageController;
  final int currentPage;
  final AnimationController glowController;

  const MainImage({
    super.key,
    required this.images,
    required this.pageController,
    required this.currentPage,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: pageController,
          itemCount: images.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Image.network(
              images[index],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey.shade400,
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.broken_image_rounded,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            );
          },
        ),

        // Indicator
        if (images.length > 1)
          Positioned(
            top: 16,
            right: 16,
            child: PageIndicator(
              current: currentPage,
              total: images.length,
              animation: glowController,
            ),
          ),
      ],
    );
  }
}

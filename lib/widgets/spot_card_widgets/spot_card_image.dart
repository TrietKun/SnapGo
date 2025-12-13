import 'package:flutter/material.dart';
import 'package:snapgo/models/spot_entity.dart';
import 'package:snapgo/widgets/spot_card_image/build_location.dart';
import 'package:snapgo/widgets/spot_card_image/build_thumbnail.dart';
import 'package:snapgo/widgets/spot_card_image/glass_section.dart';

import 'package:snapgo/widgets/spot_card_image/main_image.dart';
import 'package:snapgo/widgets/spot_card_image/spot_card_image_controller.dart';

class SpotCardImage extends StatefulWidget {
  final SpotEntity spot;

  const SpotCardImage({super.key, required this.spot});

  @override
  State<SpotCardImage> createState() => _SpotCardImageState();
}

class _SpotCardImageState extends State<SpotCardImage>
    with TickerProviderStateMixin {
  late SpotCardImageController controller;

  @override
  void initState() {
    super.initState();
    controller =
        SpotCardImageController(vsync: this, images: widget.spot.imageUrls);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = controller.images;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.2,
          child: MainImage(
            images: images,
            pageController: controller.pageController,
            currentPage: controller.currentPage.value,
            glowController: controller.glowController,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: controller.currentPage,
          builder: (_, page, __) {
            return GlassSection(
              images: images,
              loopImages: controller.loopImages,
              locationInfo: BuildLocation(
                glowAnimation: controller.glowController,
                name: widget.spot.name,
                district: widget.spot.district,
                city: widget.spot.city,
              ),
              thumbController: controller.thumbController,
              thumbnailBuilder: (i) {
                final realLen = images.length;
                final isActive = (i % realLen) == page;

                return ThumbnailItem(
                  imageUrl: controller.loopImages[i],
                  isActive: isActive,
                );
              },
            );
          },
        ),
        //nút xem hình full
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                controller.showFullscreenImageViewer(
                  context,
                  imageUrls: widget.spot.imageUrls,
                  initialIndex:
                      controller.currentPage.value, // Bắt đầu từ ảnh đang xem
                );
              },
              icon: const Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: 32,
              ),
              tooltip: 'Xem hình full',
            ),
          ),
        ),
      ],
    );
  }
}

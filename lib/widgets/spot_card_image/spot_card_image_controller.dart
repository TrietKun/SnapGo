import 'package:flutter/material.dart';
import 'package:snapgo/screens/image_viewer_screen.dart';

class SpotCardImageController {
  final TickerProvider vsync;
  final List<String> images;

  static const double itemWidth = 128.0;

  late final PageController pageController;
  late final ScrollController thumbController;

  late final AnimationController glowController;
  late final AnimationController scrollController;

  late final List<String> loopImages;

  final ValueNotifier<int> currentPage = ValueNotifier(0);

  SpotCardImageController({
    required this.vsync,
    required this.images,
  }) {
    // Loop 3 sections
    loopImages =
        images.length <= 1 ? images : [...images, ...images, ...images];

    pageController = PageController();
    thumbController = ScrollController();

    glowController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    scrollController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 100),
    );

    // Only auto-scroll if multiple images
    if (images.length > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeScroll();
      });
    }
  }

  // =====================================================
  // INITIALIZE SCROLL
  // =====================================================

  void _initializeScroll() {
    if (!thumbController.hasClients) return;

    final realLen = images.length;
    final middleStart = realLen * itemWidth;

    // Jump to middle section
    thumbController.jumpTo(middleStart);

    _startSmoothScroll();
  }

  // =====================================================
  // AUTO SCROLL
  // =====================================================

  void _startSmoothScroll() {
    final realLen = images.length;
    final sectionWidth = realLen * itemWidth;

    scrollController.addListener(() {
      if (!thumbController.hasClients) return;

      final progress = scrollController.value;
      final scrollDistance = sectionWidth * 1.5;

      double offset = sectionWidth + (progress * scrollDistance);

      if (offset >= sectionWidth * 2.3) {
        final resetOffset = sectionWidth + (offset - sectionWidth * 2);
        thumbController.jumpTo(resetOffset);
        scrollController.reset();
        scrollController.forward();
        return;
      }

      thumbController.jumpTo(offset);
      _updateMainImage();
    });

    scrollController.repeat();
  }

  // =====================================================
  // UPDATE MAIN IMAGE
  // =====================================================

  void _updateMainImage() {
    if (!thumbController.hasClients || !pageController.hasClients) return;

    final realLen = images.length;
    final middleStart = realLen * itemWidth;

    final relativeOffset = thumbController.offset - middleStart;
    int index = (relativeOffset / itemWidth).round() % realLen;

    if (index < 0) index += realLen;

    if (index != currentPage.value) {
      currentPage.value = index;

      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void showFullscreenImageViewer(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ImageViewerScreen(
              imageUrls: imageUrls,
              initialIndex: initialIndex,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  void dispose() {
    scrollController.dispose();
    glowController.dispose();
    pageController.dispose();
    thumbController.dispose();
    currentPage.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:snapgo/models/spot_entity.dart';
import 'package:snapgo/widgets/spot_card_widgets/spot_card_action_bar.dart';
import 'package:snapgo/widgets/spot_card_widgets/spot_card_content.dart';
import 'package:snapgo/widgets/spot_card_widgets/spot_card_header.dart';
import 'package:snapgo/widgets/spot_card_widgets/spot_card_image.dart';
import 'package:snapgo/widgets/spot_card_widgets/spot_card_top_user_photos.dart';

class SpotCard extends StatefulWidget {
  final SpotEntity spot;

  const SpotCard({super.key, required this.spot});

  @override
  State<SpotCard> createState() => _SpotCardState();
}

class _SpotCardState extends State<SpotCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.blue.withOpacity(0.05),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SpotCardHeader(spot: widget.spot),
              SpotCardImage(spot: widget.spot),
              SpotCardContent(spot: widget.spot),
              SpotCardTopUserPhotos(spot: widget.spot),
              SpotCardActionBar(spot: widget.spot),
            ],
          ),
        ),
      ),
    );
  }
}

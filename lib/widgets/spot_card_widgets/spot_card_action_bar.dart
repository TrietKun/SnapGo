import 'package:flutter/material.dart';
import 'package:snapgo/core/helper.dart';
import 'package:snapgo/models/spot_entity.dart';
import 'package:snapgo/widgets/spot_card_widgets/spot_card_action_button.dart';

class SpotCardActionBar extends StatefulWidget {
  const SpotCardActionBar({super.key, this.onFavoriteTap, required this.spot});

  final VoidCallback? onFavoriteTap;
  final SpotEntity spot;

  @override
  State<SpotCardActionBar> createState() => _SpotCardActionBarState();
}

class _SpotCardActionBarState extends State<SpotCardActionBar>
    with TickerProviderStateMixin {
  late bool _isFavorited = false;
  late AnimationController _controller;
  late AnimationController _checkInController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _checkInController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Row(
        children: [
          Expanded(
              child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.85).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOut,
                reverseCurve: Curves.easeIn,
              ),
            ),
            child: SpotCardActionButton(
              icon:
                  _isFavorited ? Icons.favorite : Icons.favorite_border_rounded,
              label: Helper().formatNumber(widget.spot.favorites),
              color: Colors.red.shade400,
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.pink.shade400],
              ),
              onTap: () {
                setState(() {
                  _isFavorited = !_isFavorited;
                });
                _controller.forward().then((_) => _controller.reverse());
              },
            ),
          )),
          const SizedBox(width: 8),
          Expanded(
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 0.85).animate(
                CurvedAnimation(
                  parent: _checkInController,
                  curve: Curves.easeOut,
                  reverseCurve: Curves.easeIn,
                ),
              ),
              child: SpotCardActionButton(
                icon: Icons.location_on_rounded,
                label: Helper().formatNumber(widget.spot.checkInCount),
                color: Colors.blue.shade400,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.cyan.shade400],
                ),
                onTap: () {
                  _checkInController
                      .forward()
                      .then((_) => _checkInController.reverse());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

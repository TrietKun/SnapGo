import 'package:flutter/material.dart';

class DividerCustom extends StatelessWidget {
  const DividerCustom({
    super.key,
    required int height,
    required Color color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey.shade300),
    );
  }
}

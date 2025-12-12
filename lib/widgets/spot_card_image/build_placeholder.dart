import 'package:flutter/material.dart';

class BuildPlaceholder extends StatelessWidget {
  const BuildPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.photo_rounded,
          size: 72,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
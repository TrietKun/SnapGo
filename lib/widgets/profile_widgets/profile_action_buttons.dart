import 'package:flutter/material.dart';
import 'package:snapgo/widgets/profile_widgets/gradient_button.dart';

class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: GradientButton(
            label: 'Edit Profile',
            icon: Icons.edit_outlined,
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/editProfile');
            },
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.qr_code_rounded),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('QR Code - Coming soon!')),
            );
          },
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.share_rounded),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share Profile - Coming soon!')),
            );
          },
        ),
      ],
    );
  }
}

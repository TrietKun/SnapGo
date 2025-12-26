import 'package:flutter/material.dart';
import 'package:snapgo/widgets/profile_widgets/profile_menu_card.dart';

class ProfileMenuCards extends StatelessWidget {
  const ProfileMenuCards({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        MenuCard(
          icon: Icons.person_outline_rounded,
          title: 'Account Settings',
          subtitle: 'Manage your account',
          color: colorScheme.primary,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        MenuCard(
          icon: Icons.lock_outline_rounded,
          title: 'Privacy & Security',
          subtitle: 'Control your privacy',
          color: colorScheme.secondary,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        MenuCard(
          icon: Icons.notifications_none_rounded,
          title: 'Notifications',
          subtitle: 'Manage notifications',
          color: colorScheme.tertiary,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        MenuCard(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          subtitle: 'Get help anytime',
          color: const Color(0xFF6C63FF),
          onTap: () {},
        ),
      ],
    );
  }
}

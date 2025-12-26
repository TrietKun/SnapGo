import 'package:flutter/material.dart';
import 'package:snapgo/core/helper.dart';
import 'package:snapgo/models/user_entity.dart';
import 'package:snapgo/widgets/divider.dart';
import 'package:snapgo/widgets/profile_widgets/detail_row.dart';

class ProfileUserInfo extends StatefulWidget {
  const ProfileUserInfo({super.key, required this.user});
  final UserEntity user;

  @override
  State<ProfileUserInfo> createState() => _ProfileUserInfoState();
}

class _ProfileUserInfoState extends State<ProfileUserInfo> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Name
                Text(
                  widget.user.displayName ?? widget.user.username,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 8),

                // Role Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.2),
                        colorScheme.secondary.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.user.role.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bio
                if (widget.user.bio != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    widget.user.bio!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // User Details
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                DetailRow(
                  icon: Icons.badge_outlined,
                  label: 'Full Name',
                  value: widget.user.displayName ?? 'Not set',
                  colorScheme: colorScheme,
                ),
                DividerCustom(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                DetailRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: widget.user.email,
                  colorScheme: colorScheme,
                ),
                if (widget.user.phoneNumber != null) ...[
                  DividerCustom(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  DetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: widget.user.phoneNumber!,
                    colorScheme: colorScheme,
                  ),
                ],
                DividerCustom(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Member Since',
                  value: Helper().formatDate(widget.user.createdAt),
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapgo/blocs/auth/auth_bloc.dart';
import 'package:snapgo/blocs/auth/auth_event.dart';
import 'package:snapgo/blocs/auth/auth_state.dart';
import 'package:snapgo/core/helper.dart';
import 'package:snapgo/models/app_user.dart';
import 'package:snapgo/widgets/divider.dart';
import 'package:snapgo/widgets/logout_button.dart';
import 'package:snapgo/widgets/profile_widgets/detail_row.dart';
import 'package:snapgo/widgets/profile_widgets/gradient_button.dart';
import 'package:snapgo/widgets/profile_widgets/profile_guest_view.dart';
import 'package:snapgo/widgets/profile_widgets/profile_header.dart';
import 'package:snapgo/widgets/profile_widgets/profile_menu_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const _LoadingView();
        }

        if (state is AuthAuthenticated) {
          return _AuthenticatedProfileView(user: state.user);
        }

        if (state is AuthGuest) {
          return const ProfileGuestView();
        }

        if (state is AuthError) {
          return _ErrorView(message: state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ==================== AUTHENTICATED VIEW ====================
class _AuthenticatedProfileView extends StatefulWidget {
  final UserEntity user;

  const _AuthenticatedProfileView({required this.user});

  @override
  State<_AuthenticatedProfileView> createState() =>
      _AuthenticatedProfileViewState();
}

class _AuthenticatedProfileViewState extends State<_AuthenticatedProfileView>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _floatingController;

  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Header animations
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Content animations
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _contentController, curve: Curves.easeOut));

    // Floating animation for avatar
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.05),
              colorScheme.secondary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            ProfileHeader(
              user: widget.user,
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _contentFadeAnimation,
                child: SlideTransition(
                  position: _contentSlideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildUserInfo(context, colorScheme),
                        const SizedBox(height: 24),
                        _buildActionButtons(context, colorScheme),
                        const SizedBox(height: 24),
                        _buildMenuCards(context, colorScheme),
                        const SizedBox(height: 24),
                        const LogoutButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, ColorScheme colorScheme) {
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

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile - Coming soon!')),
              );
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

  Widget _buildMenuCards(BuildContext context, ColorScheme colorScheme) {
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

// ==================== GUEST VIEW ====================

// ==================== LOADING VIEW ====================
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

// ==================== ERROR VIEW ====================
class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFFF6B6B)),
            const SizedBox(height: 16),
            Text(
              'An error occurred',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthStarted());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapgo/blocs/auth/auth_bloc.dart';
import 'package:snapgo/blocs/auth/auth_state.dart';
import 'package:snapgo/models/user_entity.dart';
import 'package:snapgo/widgets/profile_widgets/profile_action_buttons.dart';
import 'package:snapgo/widgets/profile_widgets/profile_menu_cards.dart';
import 'package:snapgo/widgets/profile_widgets/profile_user_info.dart';
import 'package:snapgo/widgets/logout_button.dart';
import 'package:snapgo/widgets/profile_widgets/profile_error_view.dart';
import 'package:snapgo/widgets/profile_widgets/profile_guest_view.dart';
import 'package:snapgo/widgets/profile_widgets/profile_header.dart';
import 'package:snapgo/widgets/profile_widgets/profile_loading_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const ProfileLoadingView();
        }

        if (state is AuthAuthenticated) {
          return _AuthenticatedProfileView(user: state.user);
        }

        if (state is AuthGuest) {
          return const ProfileGuestView();
        }

        if (state is AuthError) {
          return ProfileErrorView(message: state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

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
                        ProfileUserInfo(user: widget.user),
                        const SizedBox(height: 24),
                        const ProfileActionButtons(),
                        const SizedBox(height: 24),
                        const ProfileMenuCards(),
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
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:snapgo/blocs/auth/auth_bloc.dart';
import 'package:snapgo/blocs/auth/auth_state.dart';
import 'package:snapgo/blocs/profile/edit_profile_bloc.dart';
import 'package:snapgo/blocs/profile/edit_profile_event.dart';
import 'package:snapgo/blocs/profile/edit_profile_state.dart';
import 'package:snapgo/blocs/upload/image_upload_bloc.dart';
import 'package:snapgo/blocs/upload/image_upload_event.dart';
import 'package:snapgo/blocs/upload/image_upload_state.dart';
import 'package:snapgo/models/user_entity.dart';

// Theme Constants giữ nguyên
class LuxuryColors {
  static const primary = Color(0xFF1A1A1A);
  static const accent = Color(0xFFD4AF37);
  static const background = Color(0xFFF8F9FA);
  static const surface = Colors.white;
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator.adaptive()));
        }

        if (authState is AuthAuthenticated) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => EditProfileBloc()),
              BlocProvider(create: (_) => ImageUploadBloc()),
            ],
            child: _EditProfileView(user: authState.user),
          );
        }

        return const Scaffold(
            body: Center(child: Text('Please sign in to continue')));
      },
    );
  }
}

class _EditProfileView extends StatefulWidget {
  final UserEntity user;
  const _EditProfileView({required this.user});

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView>
    with TickerProviderStateMixin {
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;

  String? _uploadedAvatarUrl;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _displayNameController =
        TextEditingController(text: widget.user.displayName);
    _bioController = TextEditingController(text: widget.user.bio);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (image != null) {
      HapticFeedback.mediumImpact();
      // Gửi event để hiển thị preview
      context.read<ImageUploadBloc>().add(ImageSelected(image.path));
      _showImagePreviewDialog(image.path);
    }
  }

  void _showImagePreviewDialog(String imagePath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: context.read<ImageUploadBloc>(),
          ),
          BlocProvider.value(
            value: context.read<EditProfileBloc>(),
          ),
        ],
        child: BlocConsumer<ImageUploadBloc, ImageUploadState>(
          listener: (context, state) {
            if (state is ImageUploadSuccess) {
              context.read<EditProfileBloc>().add(
                    AvatarUploaded(
                      userId: widget.user.id,
                      avatarUrl: state.uploadedUrl,
                    ),
                  );
              // Lưu URL đã upload
              setState(() {
                _uploadedAvatarUrl = state.uploadedUrl;
              });
              // Đóng dialog và show snackbar
              Navigator.pop(dialogContext);
              _showSnackBar(
                'Image uploaded successfully!',
                LuxuryColors.success,
              );
            } else if (state is ImageUploadFailure) {
              Navigator.pop(dialogContext);
              _showSnackBar(
                'Upload failed: ${state.error}',
                LuxuryColors.error,
              );
            }
          },
          builder: (context, uploadState) {
            final isUploading = uploadState is ImageUploading;
            final progress =
                uploadState is ImageUploading ? uploadState.progress : 0.0;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Preview ảnh
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(imagePath),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Progress indicator khi đang upload
                    if (isUploading) ...[
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(
                          LuxuryColors.accent,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Uploading... ${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: LuxuryColors.accent,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Buttons
                    if (!isUploading)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                context.read<ImageUploadBloc>().add(
                                      ImageUploadCancelled(),
                                    );
                                Navigator.pop(dialogContext);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Gửi event để upload avatar (tự động optimize)
                                context.read<ImageUploadBloc>().add(
                                      AvatarUploadRequested(
                                        imagePath: imagePath,
                                        folder: 'avatars',
                                      ),
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: LuxuryColors.accent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Upload',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                backgroundColor == LuxuryColors.success
                    ? Icons.check_circle_rounded
                    : Icons.error_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileBloc, EditProfileState>(
      listener: (context, state) {
        if (state is EditProfileSuccess) {
          _showSuccessUI(context);
        } else if (state is EditProfileFailure) {
          _showSnackBar(state.message, LuxuryColors.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is EditProfileLoading;

        return Scaffold(
          backgroundColor: LuxuryColors.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, isLoading),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildAvatarSection(),
                        const SizedBox(height: 40),
                        _buildFormSection(),
                        const SizedBox(height: 32),
                        _buildAccountSection(),
                        const SizedBox(height: 32),
                        _buildStatsSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, bool isLoading) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: LuxuryColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: LuxuryColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: const FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'EDIT PROFILE',
          style: TextStyle(
            color: LuxuryColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2.5,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: BlocBuilder<ImageUploadBloc, ImageUploadState>(
            builder: (context, uploadState) {
              final isUploadingImage = uploadState is ImageUploading;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isLoading || isUploadingImage
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(
                            LuxuryColors.accent,
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: _canSubmit() ? _submit : null,
                        icon: Icon(
                          Icons.check_circle_rounded,
                          color: _canSubmit()
                              ? LuxuryColors.accent
                              : Colors.grey.shade400,
                          size: 32,
                        ),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _canSubmit() {
    return _displayNameController.text.trim().isNotEmpty;
  }

  Widget _buildAvatarSection() {
    return BlocBuilder<ImageUploadBloc, ImageUploadState>(
      builder: (context, uploadState) {
        return Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: uploadState is ImageUploading ? null : _pickImage,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Hero(
                        tag: 'avatar',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _uploadedAvatarUrl != null
                                  ? LuxuryColors.accent
                                  : Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_uploadedAvatarUrl != null
                                        ? LuxuryColors.accent
                                        : Colors.black)
                                    .withOpacity(0.15),
                                blurRadius: 24,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _getAvatarImage(),
                            child: _getAvatarImage() == null
                                ? const Icon(Icons.person_outline,
                                    size: 60, color: Colors.grey)
                                : null,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              LuxuryColors.primary,
                              LuxuryColors.accent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: LuxuryColors.accent.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedOpacity(
                opacity: uploadState is ImageUploadSuccess ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: LuxuryColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: LuxuryColors.accent.withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_done_rounded,
                        size: 16,
                        color: LuxuryColors.accent,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Uploaded ✓',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: LuxuryColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ImageProvider? _getAvatarImage() {
    if (_uploadedAvatarUrl != null && _uploadedAvatarUrl!.isNotEmpty) {
      return NetworkImage(_uploadedAvatarUrl!);
    }

    if (widget.user.avatarUrl != null && widget.user.avatarUrl!.isNotEmpty) {
      return NetworkImage(widget.user.avatarUrl!);
    }

    return null;
  }

  // Các widget khác giữ nguyên như code cũ
  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Personal Information', Icons.person_rounded),
          const SizedBox(height: 20),
          _buildElegantTextField(
            label: 'DISPLAY NAME',
            controller: _displayNameController,
            icon: Icons.badge_outlined,
            hint: 'Enter your full name',
          ),
          const SizedBox(height: 20),
          _buildElegantTextField(
            label: 'BIOGRAPHY',
            controller: _bioController,
            maxLines: 4,
            icon: Icons.edit_note_rounded,
            hint: 'Tell us about yourself...',
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Account Details', Icons.security_rounded),
          const SizedBox(height: 20),
          _buildReadOnlyTile(
            'Email Address',
            widget.user.email,
            Icons.alternate_email_rounded,
          ),
          const SizedBox(height: 12),
          _buildReadOnlyTile(
            'Membership',
            widget.user.role.name.toUpperCase(),
            Icons.workspace_premium_rounded,
          ),
          const SizedBox(height: 12),
          _buildReadOnlyTile(
            'Member Since',
            _formatDate(widget.user.createdAt.toString()),
            Icons.calendar_today_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LuxuryColors.primary,
            LuxuryColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: LuxuryColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded,
                  color: LuxuryColors.accent, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Your Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _LuxuryStatsGrid(stats: widget.user.stats),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: LuxuryColors.accent, size: 22),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildElegantTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: LuxuryColors.primary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: LuxuryColors.accent, size: 22),
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: LuxuryColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: LuxuryColors.accent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_canSubmit()) return;

    HapticFeedback.mediumImpact();

    // Sử dụng _uploadedAvatarUrl nếu có upload ảnh mới
    // Ngược lại giữ nguyên avatarUrl cũ
    final avatarUrl = _uploadedAvatarUrl ?? widget.user.avatarUrl;

    context.read<EditProfileBloc>().add(
          EditProfileSubmitted(
            userId: widget.user.id,
            displayName: _displayNameController.text.trim(),
            bio: _bioController.text.trim(),
            avatarPath: avatarUrl,
          ),
        );
  }

  void _showSuccessUI(BuildContext context) {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: LuxuryColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: LuxuryColors.success,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Profile Updated!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your changes have been saved successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}

// Stats Grid widget giữ nguyên
class _LuxuryStatsGrid extends StatelessWidget {
  final UserStats stats;
  const _LuxuryStatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatItem('POSTS', stats.posts, Icons.article_rounded),
        _buildStatItem('FOLLOWERS', stats.followers, Icons.people_rounded),
        _buildStatItem('SPOTS', stats.spotsVisited, Icons.location_on_rounded),
        _buildStatItem(
            'PHOTOS', stats.photosShared, Icons.photo_library_rounded),
      ],
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: LuxuryColors.accent, size: 24),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.0,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

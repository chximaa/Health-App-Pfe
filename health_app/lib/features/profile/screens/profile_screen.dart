import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/health_card.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final auth = ref.watch(authProvider);

    final name = profile?.fullName ?? 'User';
    final email = auth is AuthAuthenticated ? auth.user.email : '';

    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Health Metrics
                if (profile != null) ...[
                  const SectionHeader(title: 'Health Profile'),
                  const SizedBox(height: 14),
                  HealthCard(
                    child: Column(
                      children: [
                        _MetricRow(
                          icon: Icons.cake_outlined,
                          label: 'Age',
                          value: profile.age != null
                              ? '${profile.age} years'
                              : 'Not set',
                        ),
                        const Divider(height: 24),
                        _MetricRow(
                          icon: Icons.monitor_weight_outlined,
                          label: 'Weight',
                          value: profile.weightKg != null
                              ? '${profile.weightKg} kg'
                              : 'Not set',
                        ),
                        const Divider(height: 24),
                        _MetricRow(
                          icon: Icons.height_rounded,
                          label: 'Height',
                          value: profile.heightCm != null
                              ? '${profile.heightCm} cm'
                              : 'Not set',
                        ),
                        if (profile.bloodType != null) ...[
                          const Divider(height: 24),
                          _MetricRow(
                            icon: Icons.bloodtype_outlined,
                            label: 'Blood Type',
                            value: profile.bloodType!,
                          ),
                        ],
                        if (profile.gender != null) ...[
                          const Divider(height: 24),
                          _MetricRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Gender',
                            value: profile.gender![0].toUpperCase() +
                                profile.gender!.substring(1),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Medical conditions
                if (profile?.medicalConditions.isNotEmpty == true) ...[
                  const SectionHeader(title: 'Medical Conditions'),
                  const SizedBox(height: 14),
                  HealthCard(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile!.medicalConditions.map((c) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.error.withOpacity(0.2)),
                          ),
                          child: Text(
                            c,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Settings
                const SectionHeader(title: 'Settings'),
                const SizedBox(height: 14),
                HealthCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.edit_outlined,
                        label: 'Edit Profile',
                        onTap: () => context.push('/profile-setup'),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.download_outlined,
                        label: 'Export Health Data',
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy & Security',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Logout
                HealthCard(
                  padding: EdgeInsets.zero,
                  withShadow: false,
                  child: _SettingsTile(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    iconColor: AppColors.error,
                    labelColor: AppColors.error,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text(
                              'Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text('Sign Out',
                                  style:
                                      TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await ref.read(authProvider.notifier).logout();
                        context.go('/login');
                      }
                    },
                    showChevron: false,
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondary, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final bool showChevron;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.secondary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.secondary,
          size: 18,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: labelColor ?? AppColors.textPrimary,
        ),
      ),
      trailing: showChevron
          ? const Icon(Icons.chevron_right_rounded,
              color: AppColors.textHint)
          : null,
    );
  }
}

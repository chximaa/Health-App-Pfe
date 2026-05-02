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

    final name = profile?.fullName ?? 'Student';
    final email = auth is AuthAuthenticated ? auth.user.email : '';
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Profile hero ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
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
                // ── Health profile ─────────────────────────────────────
                if (profile != null) ...[
                  const SectionHeader(title: 'Health Profile'),
                  const SizedBox(height: 14),
                  HealthCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _MetricTile(
                          icon: Icons.cake_outlined,
                          label: 'Age',
                          value: profile.age != null
                              ? '${profile.age} years'
                              : 'Not set',
                        ),
                        _Divider(),
                        _MetricTile(
                          icon: Icons.monitor_weight_outlined,
                          label: 'Weight',
                          value: profile.weightKg != null
                              ? '${profile.weightKg} kg'
                              : 'Not set',
                        ),
                        _Divider(),
                        _MetricTile(
                          icon: Icons.height_rounded,
                          label: 'Height',
                          value: profile.heightCm != null
                              ? '${profile.heightCm} cm'
                              : 'Not set',
                        ),
                        if (profile.bloodType != null) ...[
                          _Divider(),
                          _MetricTile(
                            icon: Icons.bloodtype_outlined,
                            label: 'Blood Type',
                            value: profile.bloodType!,
                          ),
                        ],
                        if (profile.gender != null) ...[
                          _Divider(),
                          _MetricTile(
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

                // ── Medical conditions ─────────────────────────────────
                if (profile?.medicalConditions.isNotEmpty == true) ...[
                  const SectionHeader(title: 'Medical Conditions'),
                  const SizedBox(height: 12),
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

                // ── Settings ───────────────────────────────────────────
                const SectionHeader(title: 'Settings'),
                const SizedBox(height: 12),
                HealthCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.edit_outlined,
                        label: 'Edit Profile',
                        onTap: () => context.push('/profile-setup'),
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () {},
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.download_outlined,
                        label: 'Export Health Data',
                        onTap: () {},
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy & Security',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Sign out ───────────────────────────────────────────
                HealthCard(
                  padding: EdgeInsets.zero,
                  withShadow: false,
                  child: _SettingsTile(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    iconColor: AppColors.error,
                    labelColor: AppColors.error,
                    showChevron: false,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
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
                                  style: TextStyle(
                                      color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await ref.read(authProvider.notifier).logout();
                        context.go('/login');
                      }
                    },
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

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 56, endIndent: 0);
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 17),
          ),
          const SizedBox(width: 14),
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
      ),
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
    final color = iconColor ?? AppColors.primary;
    return ListTile(
      onTap: onTap,
      minLeadingWidth: 0,
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 17),
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
              color: AppColors.textHint, size: 20)
          : null,
    );
  }
}

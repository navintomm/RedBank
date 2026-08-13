import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/redbank_scaffold.dart';
import '../../../../core/widgets/surface_card.dart';

import 'donor_profile_screen.dart';
import 'availability_settings_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RedBankScaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildSectionHeader('Account', isDark),
          _buildSettingsGroup(
            isDark,
            [
              _buildSettingsTile(
                context,
                icon: Icons.person_outline,
                title: 'Donor Profile',
                subtitle: 'Manage your personal details',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DonorProfileScreen()));
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.event_available_outlined,
                title: 'Availability Settings',
                subtitle: 'Update your donation readiness',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AvailabilitySettingsScreen()));
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          _buildSectionHeader('Preferences', isDark),
          _buildSettingsGroup(
            isDark,
            [
              _buildSettingsTile(
                context,
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                subtitle: 'Configure alerts and updates',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                },
              ),
              _buildSettingsTile(
                context,
                icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                title: 'Appearance',
                subtitle: 'Theme is synced with system settings',
                onTap: null, // Read only for now
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          _buildSectionHeader('Support & Legal', isDark),
          _buildSettingsGroup(
            isDark,
            [
              _buildSettingsTile(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Version 1.0.0',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          SurfaceCard(
            elevated: false,
            onTap: () {
              // Perform logout
            },
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, color: AppColors.error),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Log Out',
                  style: AppTypography.getTextTheme(isDark: isDark).titleMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.getTextTheme(isDark: isDark).labelSmall?.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(bool isDark, List<Widget> children) {
    return SurfaceCard(
      elevated: false,
      padding: EdgeInsets.zero,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: AppTypography.getTextTheme(isDark: isDark).bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTypography.getTextTheme(isDark: isDark).bodySmall?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            )
          : null,
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
    );
  }
}

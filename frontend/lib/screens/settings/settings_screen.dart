
import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/settings_item.dart';
import '../../widgets/settings/settings_menu_item.dart';

/// Settings tab — profile header, notification bell, menu rows.
///
/// Menu items are built from a [SettingsItem] list so the layout
/// contains no business logic — just data → widget mapping.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt    = Theme.of(context).textTheme;
    final items = _buildItems(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar row ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Invisible spacer so title stays centred
                  const SizedBox(width: 36),
                  Text('Settings', style: tt.headlineMedium),
                  // Notification bell with red badge
                  _NotificationBell(count: 1),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Profile card ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ProfileCard(),
            ),
            const SizedBox(height: 24),

            // ── Menu list ─────────────────────────────────────────────
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color:        AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border:       Border.all(color: AppColors.borderColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ListView.builder(
                    padding:     EdgeInsets.zero,
                    itemCount:   items.length,
                    itemBuilder: (_, i) => SettingsMenuItem(item: items[i]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Builds the ordered list of menu items.
  /// [onTap] callbacks are placeholders — replace with actual navigation.
  List<SettingsItem> _buildItems(BuildContext context) => [
    SettingsItem(
      icon:  Icons.person_outline,
      label: 'Account Settings',
      onTap: () {},
    ),
    SettingsItem(
      icon:  Icons.person_outline,
      label: 'Developer Tools',
      onTap: () {},
    ),
    SettingsItem(
      icon:  Icons.person_outline,
      label: 'Compliance Rules',
      onTap: () {},
    ),
    SettingsItem(
      icon:  Icons.person_outline,
      label: 'Legal',
      onTap: () {},
    ),
    SettingsItem(
      icon:  Icons.person_outline,
      label: 'Logout',
      // Logout returns to the sign-in screen
      onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.signIn,
        (_) => false,
      ),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Private widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Bell icon with a small numbered red badge.
class _NotificationBell extends StatelessWidget {
  final int count;
  const _NotificationBell({required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(
          Icons.notifications_outlined,
          size:  28,
          color: AppColors.textDark,
        ),
        if (count > 0)
          Positioned(
            top:   -4,
            right: -4,
            child: Container(
              width:  16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.riskHighFg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:    AppColors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Profile header card: avatar · name row · edit icon.
/// Avatar uses a placeholder grey circle; replace with [CircleAvatar]
/// loading a real image URL once user data is available.
class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius:          28,
            backgroundColor: AppColors.surfaceGrey,
            child: const Icon(
              Icons.person,
              size:  32,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(width: 14),

          // Name + role row
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size:  16,
                  color: AppColors.textGrey,
                ),
                const SizedBox(width: 6),
                Text('Account Settings', style: tt.bodyLarge),
              ],
            ),
          ),

          // Edit pencil icon
          const Icon(Icons.edit_outlined, size: 20, color: AppColors.textGrey),
        ],
      ),
    );
  }
}

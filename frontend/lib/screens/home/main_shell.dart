import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/sensor_provider.dart';
import '../alerts/alerts_screen.dart';
import '../sensors/sensors_screen.dart';
import '../settings/settings_screen.dart';
import 'home_screen.dart';

/// Root navigation shell that hosts the four main tabs and the centre FAB.
///
/// Tab index map:
///   0 → Home
///   1 → Sensors
///   2 → Alerts
///   3 → Settings
///
/// FAB: opens the AI Advisory Chat.  The most recently viewed sensor is used
/// as context; if no sensor has been loaded yet the FAB is a no-op with a
/// tooltip explaining why.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  /// Pages rendered by [IndexedStack] — all stay alive while the shell is mounted.
  static const _pages = [
    HomeScreen(),
    SensorsScreen(),
    AlertsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Kick off sensor load as soon as the shell mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SensorProvider>().loadSensors();
    });
  }

  /// Opens the AI chat with the first available sensor as context.
  /// Shown as the centre FAB — the purple sparkle button the user sees.
  void _openAiChat() {
    final sensors = context.read<SensorProvider>().sensors;
    if (sensors.isEmpty) {
      // Sensors not loaded yet — inform the user gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No sensors available for AI chat yet.'),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    // Use the first sensor as the default advisory context.
    // In a real flow the user would pick a sensor first.
    Navigator.of(context).pushNamed(
      AppRoutes.aiChat,
      arguments: sensors.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index:    _currentIndex,
        children: _pages,
      ),

      // ── Centre AI FAB ──────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed:       _openAiChat,
        backgroundColor: AppColors.aiFab,
        shape:           const CircleBorder(),
        tooltip:         'AI Advisory Chat',
        child: const Icon(Icons.auto_awesome, color: AppColors.white, size: 22),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Bottom navigation bar ──────────────────────────────────────
      bottomNavigationBar: BottomAppBar(
        shape:       const CircularNotchedRectangle(),
        notchMargin: 8,
        color:       AppColors.white,
        elevation:   8,
        child: Row(
          children: [
            _NavItem(
              icon:    Icons.home_outlined,
              label:   'Home',
              index:   0,
              current: _currentIndex,
              onTap:   _setIndex,
            ),
            _NavItem(
              icon:    Icons.sensors,
              label:   'Sensor',
              index:   1,
              current: _currentIndex,
              onTap:   _setIndex,
            ),
            const SizedBox(width: 60), // notch spacer
            _NavItem(
              icon:    Icons.notifications_outlined,
              label:   'Alerts',
              index:   2,
              current: _currentIndex,
              onTap:   _setIndex,
            ),
            _NavItem(
              icon:    Icons.settings_outlined,
              label:   'Settings',
              index:   3,
              current: _currentIndex,
              onTap:   _setIndex,
            ),
          ],
        ),
      ),
    );
  }

  void _setIndex(int i) => setState(() => _currentIndex = i);
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav bar item
// ─────────────────────────────────────────────────────────────────────────────

/// A single bottom-nav tab item with icon + label.
/// Active items use [AppColors.teal]; inactive use [AppColors.textGrey].
class _NavItem extends StatelessWidget {
  final IconData          icon;
  final String            label;
  final int               index;
  final int               current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return Expanded(
      child: GestureDetector(
        onTap:     () => onTap(index),
        behavior:  HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size:  22,
              color: isActive ? AppColors.teal : AppColors.textGrey,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color:      isActive ? AppColors.teal : AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

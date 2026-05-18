
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/alert_model.dart';
import '../../providers/alert_provider.dart';
import '../../widgets/alerts/alert_filter_tabs.dart';
import '../../widgets/alerts/alert_list_tile.dart';
import '../../widgets/home/search_bar_widget.dart';

/// Alerts tab — filterable, searchable list of sensor alerts grouped by date.
///
/// Header: title · filter tabs (All / Alerts / Recommendation)
/// Body:   search bar · date-grouped list · empty state
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final _searchController = SearchBarController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AlertProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Title ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Text('Alerts', style: tt.headlineMedium)),
                      const SizedBox(height: 16),

                      // ── Filter tabs ──────────────────────────────────
                      AlertFilterTabs(
                        active:          provider.filter,
                        onFilterChanged: provider.setFilter,
                      ),
                      const SizedBox(height: 14),

                      // ── Search bar (no add button on this screen) ────
                      SearchBarWidget(
                        hint:       'Search alerts',
                        controller: _searchController,
                        onChanged:  provider.setSearchQuery,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Alert list / empty state ────────────────────────────
                Expanded(
                  child: _buildBody(context, provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AlertProvider provider) {
    final groups = provider.groupedAlerts;

    if (groups.isEmpty) {
      return _EmptyState(
        onClear: () {
          _searchController.clear();
          provider.clearSearch();
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 100),
      itemCount: groups.length,
      itemBuilder: (context, gi) {
        final group = groups[gi];
        return _AlertGroup(
          label:  group.label,
          alerts: group.alerts,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Date header + list of [AlertListTile]s for one day.
class _AlertGroup extends StatelessWidget {
  final String           label;
  final List<AlertModel> alerts;

  const _AlertGroup({required this.label, required this.alerts});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header, e.g. "Today, May 14"
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(label, style: tt.titleSmall?.copyWith(color: AppColors.textDark)),
        ),
        // Alert rows — full bleed (no horizontal padding; left bar handles edge)
        ...alerts.map((a) => AlertListTile(alert: a)),
      ],
    );
  }
}

/// Shown when no alerts match the current filter + search combination.
class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;
  const _EmptyState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none,
              size:  56,
              color: AppColors.textGrey,
            ),
            const SizedBox(height: 12),
            Text('No alerts found', style: tt.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Try a different filter or search term',
              style:     tt.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onClear,
              child: Text(
                'Clear search',
                style: tt.bodyMedium?.copyWith(
                  color:      AppColors.teal,
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

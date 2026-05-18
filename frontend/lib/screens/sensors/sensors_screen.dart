import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/sensor_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/home/search_bar_widget.dart';
import '../../widgets/sensors/add_sensor_sheet.dart';
import '../../widgets/sensors/edit_sensor_sheet.dart';
import '../../widgets/sensors/sensor_card.dart';

/// Sensors tab — searchable list, add/edit sensors, empty state.
///
/// Search is scoped to [SensorSearchScope.sensors] so it does not
/// interfere with the Home tab's search query.
class SensorsScreen extends StatefulWidget {
  const SensorsScreen({super.key});

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  /// Controller wires the search bar's text field to this screen so
  /// we can clear it programmatically (e.g. when the user navigates away).
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
        child: Consumer<SensorProvider>(
          builder: (context, provider, _) {
            final sensors = provider.filteredSensors(
              scope: SensorSearchScope.sensors,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: [
                      Text('Sensors', style: tt.headlineMedium),
                      const SizedBox(height: 14),

                      // Search bar + add button
                      Row(
                        children: [
                          Expanded(
                            child: SearchBarWidget(
                              controller: _searchController,
                              onChanged:  (q) => provider.setSearchQuery(
                                q,
                                scope: SensorSearchScope.sensors,
                              ),
                            ),
                          ),
                          if (provider.sensors.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            _AddButton(
                              onTap: () => showAddSensorSheet(context),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Body ─────────────────────────────────────────────────
                Expanded(
                  child: _buildBody(context, provider, sensors),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SensorProvider provider,
    List sensors,
  ) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.teal),
      );
    }

    if (provider.sensors.isEmpty) {
      return _EmptyState(onAddSensor: () => showAddSensorSheet(context));
    }

    // Non-empty list but search returned no matches
    if (sensors.isEmpty) {
      return _NoResults(
        onClear: () {
          _searchController.clear();
          provider.clearSearch(scope: SensorSearchScope.sensors);
        },
      );
    }

    return RefreshIndicator(
      color:     AppColors.teal,
      onRefresh: provider.loadSensors,
      child: ListView.builder(
        padding:     const EdgeInsets.fromLTRB(20, 4, 20, 100),
        itemCount:   sensors.length,
        itemBuilder: (context, i) {
          final sensor = sensors[i];
          return SensorCard(
            sensor: sensor,
            onTap:  () => Navigator.of(context).pushNamed(
              AppRoutes.sensorDetail,
              arguments: sensor,
            ),
            onEdit: () => showEditSensorSheet(context, sensor),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Teal + button shown in the search row when sensors exist.
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color:        AppColors.teal,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, color: AppColors.white, size: 22),
      ),
    );
  }
}

/// Shown when the sensor list is completely empty (no sensors added yet).
class _EmptyState extends StatelessWidget {
  final VoidCallback onAddSensor;
  const _EmptyState({required this.onAddSensor});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No Sensor Yet.',   style: tt.headlineSmall),
          const SizedBox(height: 6),
          Text('Add your first sensor', style: tt.bodyMedium),
          const SizedBox(height: 28),
          AppButton(label: 'Add New Sensor', onPressed: onAddSensor),
        ],
      ),
    );
  }
}

/// Shown when sensors exist but the current search query matches nothing.
class _NoResults extends StatelessWidget {
  final VoidCallback onClear;
  const _NoResults({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.search_off, size: 52, color: AppColors.textGrey),
        const SizedBox(height: 16),
        Text('No sensors found', style: tt.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Try a different sensor ID, name, or location',
          style:     tt.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
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
    );
  }
}

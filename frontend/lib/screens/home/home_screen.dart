import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/sensor_provider.dart';
import '../../widgets/home/ai_assistant_banner.dart';
import '../../widgets/home/search_bar_widget.dart';
import '../../widgets/sensors/edit_sensor_sheet.dart';
import '../../widgets/sensors/sensor_card.dart';

/// Home tab — welcome, AI banner, scoped search, recent sensors.
///
/// Uses [SensorSearchScope.home] so its query is completely independent
/// from the Sensors tab search.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            final recent = provider.filteredRecentSensors(count: 3);

            return RefreshIndicator(
              color:     AppColors.teal,
              onRefresh: provider.loadSensors,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Welcome row ────────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Welcome Meggie 👋', style: tt.headlineMedium),
                              // Notification bell with red dot badge
                              Stack(
                                children: [
                                  const Icon(
                                    Icons.notifications_outlined,
                                    size: 26,
                                    color: AppColors.textDark,
                                  ),
                                  Positioned(
                                    top: 0, right: 0,
                                    child: Container(
                                      width: 9, height: 9,
                                      decoration: const BoxDecoration(
                                        color: AppColors.riskHighFg,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Search ──────────────────────────────────────
                          SearchBarWidget(
                            controller: _searchController,
                            onChanged: (q) => provider.setSearchQuery(
                              q,
                              scope: SensorSearchScope.home,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── AI banner ───────────────────────────────────
                          const AiAssistantBanner(),
                          const SizedBox(height: 24),

                          // ── Recent Sensors header ───────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Recent Sensors', style: tt.titleMedium),
                              GestureDetector(
                                onTap: () {}, // tab switch handled by MainShell
                                child: Text(
                                  'See all',
                                  style: tt.bodyMedium?.copyWith(
                                    color:      AppColors.teal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  // ── Sensor list / empty / loading ─────────────────────
                  if (provider.isLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.teal),
                      ),
                    )
                  else if (recent.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 48,
                                color: AppColors.textGrey,
                              ),
                              const SizedBox(height: 12),
                              Text('No sensors match your search',
                                  style: tt.bodyMedium, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  provider.clearSearch(scope: SensorSearchScope.home);
                                },
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
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            if (i >= recent.length) return null;
                            final sensor = recent[i];
                            return SensorCard(
                              sensor: sensor,
                              onTap:  () => Navigator.of(context).pushNamed(
                                AppRoutes.sensorDetail,
                                arguments: sensor,
                              ),
                              onEdit: () => showEditSensorSheet(context, sensor),
                            );
                          },
                          childCount: recent.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

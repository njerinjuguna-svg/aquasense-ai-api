import 'package:flutter/material.dart';
import '../models/alert_model.dart';

/// Manages the alert list, active filter, and search query for [AlertsScreen].
class AlertProvider extends ChangeNotifier {
  AlertProvider() {
    _loadAlerts();
  }

  // ── State ────────────────────────────────────────────────────────────────

  List<AlertModel> _alerts = [];
  AlertFilter      _filter = AlertFilter.all;
  String           _query  = '';

  AlertFilter get filter => _filter;

  // ── Load (mock) ──────────────────────────────────────────────────────────

  void _loadAlerts() {
    final today     = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    _alerts = [
      AlertModel(
        id:          'a1',
        title:       'Oregun pH Line',
        description: 'Threshold breach. pH>90',
        reading:     '4.8 pH',
        safeRange:   '6.5 – 6.8',
        type:        AlertType.alert,
        timestamp:   DateTime(today.year, today.month, today.day, 12, 24),
      ),
      AlertModel(
        id:          'a2',
        title:       'Sensor offline/malfunction',
        description: 'Threshold breach. pH>90',
        reading:     '4.8 pH',
        safeRange:   '6.5 – 6.8',
        type:        AlertType.alert,
        timestamp:   DateTime(today.year, today.month, today.day, 12, 24),
      ),
      AlertModel(
        id:          'a3',
        title:       'AI Anomaly detection (pattern-based risk)',
        description: 'Threshold breach. pH>90',
        reading:     '4.8 pH',
        safeRange:   '6.5 – 6.8',
        type:        AlertType.anomaly,
        timestamp:   DateTime(today.year, today.month, today.day, 12, 24),
      ),
      AlertModel(
        id:          'a4',
        title:       'Compliance breach prediction',
        description: 'Threshold breach. pH>90',
        reading:     '4.8 pH',
        safeRange:   '6.5 – 6.8',
        type:        AlertType.compliance,
        timestamp:   DateTime(today.year, today.month, today.day, 12, 24),
      ),
      AlertModel(
        id:          'a5',
        title:       'AI Anomaly detection (pattern-based risk)',
        description: 'Threshold breach. pH>90',
        reading:     '4.8 pH',
        safeRange:   '6.5 – 6.8',
        type:        AlertType.anomaly,
        timestamp:   DateTime(yesterday.year, yesterday.month, yesterday.day, 12, 24),
      ),
      AlertModel(
        id:          'a6',
        title:       'Dosing pump recommendation',
        description: 'Adjust neutralisation buffer',
        reading:     '5.1 pH',
        safeRange:   '6.5 – 8.5',
        type:        AlertType.recommendation,
        timestamp:   DateTime(yesterday.year, yesterday.month, yesterday.day, 14, 0),
      ),
    ];

    notifyListeners();
  }

  // ── Filter ───────────────────────────────────────────────────────────────

  void setFilter(AlertFilter f) {
    _filter = f;
    notifyListeners();
  }

  // ── Search ───────────────────────────────────────────────────────────────

  void setSearchQuery(String q) {
    _query = q.toLowerCase();
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    notifyListeners();
  }

  // ── Derived ──────────────────────────────────────────────────────────────

  /// Alerts matching the active filter and search query.
  List<AlertModel> get visibleAlerts {
    return _alerts.where((a) {
      final matchesFilter = _filter.matches(a.type);
      final matchesQuery  = _query.isEmpty ||
          a.title.toLowerCase().contains(_query) ||
          a.description.toLowerCase().contains(_query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  /// Alerts grouped by calendar day, sorted newest-first.
  ///
  /// Returns a list of `(dateLabel, alerts)` pairs, e.g.:
  ///   `[('Today, May 14', [...]), ('Yesterday, May 13', [...])]`
  List<({String label, List<AlertModel> alerts})> get groupedAlerts {
    final visible = visibleAlerts
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // newest first
    if (visible.isEmpty) return [];

    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Bucket by date string
    final Map<String, List<AlertModel>> buckets = {};
    for (final alert in visible) {
      final d   = alert.timestamp;
      final day = DateTime(d.year, d.month, d.day);
      final diff = today.difference(day).inDays;

      final String label;
      if (diff == 0) {
        label = 'Today, ${_monthName(d.month)} ${d.day}';
      } else if (diff == 1) {
        label = 'Yesterday, ${_monthName(d.month)} ${d.day}';
      } else {
        label = '${_monthName(d.month)} ${d.day}';
      }
      buckets.putIfAbsent(label, () => []).add(alert);
    }

    return buckets.entries
        .map((e) => (label: e.key, alerts: e.value))
        .toList();
  }
  String _monthName(int month) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ][month];
}
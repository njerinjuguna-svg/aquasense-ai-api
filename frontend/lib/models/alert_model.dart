/// Category of an alert — controls the left accent colour and filter tab.
enum AlertType {
  alert,
  recommendation,
  anomaly,
  compliance;

  String get label {
    switch (this) {
      case AlertType.alert:          return 'Alert';
      case AlertType.recommendation: return 'Recommendation';
      case AlertType.anomaly:        return 'AI Anomaly';
      case AlertType.compliance:     return 'Compliance';
    }
  }
}

/// A single alert entry shown in the Alerts screen list.
class AlertModel {
  final String    id;
  final String    title;
  final String    description;
  /// Sensor reading snapshot, e.g. "4.8 pH".
  final String    reading;
  /// Safe operating range, e.g. "6.5 – 6.8".
  final String    safeRange;
  final AlertType type;
  final DateTime  timestamp;

  const AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.reading,
    required this.safeRange,
    required this.type,
    required this.timestamp,
  });

  /// One-line reading + safe range shown beneath the description.
  String get readingLine => '$reading | Safe: $safeRange';
}

/// Filter state for the Alerts screen tab bar.
enum AlertFilter {
  all,
  alerts,
  recommendation;

  String get label {
    switch (this) {
      case AlertFilter.all:            return 'All';
      case AlertFilter.alerts:         return 'Alerts';
      case AlertFilter.recommendation: return 'Recommendation';
    }
  }

  /// Returns true if [type] should be visible under this filter.
  bool matches(AlertType type) {
    switch (this) {
      case AlertFilter.all:
        return true;
      case AlertFilter.alerts:
        return type == AlertType.alert || type == AlertType.anomaly || type == AlertType.compliance;
      case AlertFilter.recommendation:
        return type == AlertType.recommendation;
    }
  }
}

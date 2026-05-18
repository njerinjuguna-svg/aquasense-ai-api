/// Risk level of a sensor reading — drives badge colour and AI alerts.
enum RiskLevel {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case RiskLevel.low:    return 'low';
      case RiskLevel.medium: return 'medium';
      case RiskLevel.high:   return 'high';
    }
  }
}

/// The physical quantity a sensor measures.
enum ParameterType {
  pH,
  turbidity,
  dissolvedOxygen,
  temperature,
  conductivity,
  other;

  String get label {
    switch (this) {
      case ParameterType.pH:              return 'pH';
      case ParameterType.turbidity:       return 'Turbidity';
      case ParameterType.dissolvedOxygen: return 'Dissolved Oxygen';
      case ParameterType.temperature:     return 'Temperature';
      case ParameterType.conductivity:    return 'Conductivity';
      case ParameterType.other:           return 'Other';
    }
  }

  String get unit {
    switch (this) {
      case ParameterType.pH:              return 'pH';
      case ParameterType.turbidity:       return 'NTU';
      case ParameterType.dissolvedOxygen: return 'mg/L';
      case ParameterType.temperature:     return '°C';
      case ParameterType.conductivity:    return 'µS/cm';
      case ParameterType.other:           return '';
    }
  }
}

/// Trend direction of the latest sensor reading.
enum TrendDirection { up, down, stable }

/// How the sensor transmits data to the platform.
enum DataSourceType {
  iot,
  manual,
  modbus,
  mqtt;

  String get label {
    switch (this) {
      case DataSourceType.iot:    return 'IoT Device';
      case DataSourceType.manual: return 'Manual Entry';
      case DataSourceType.modbus: return 'Modbus';
      case DataSourceType.mqtt:   return 'MQTT';
    }
  }
}

/// AI advisory sensitivity — controls how aggressively alerts fire.
enum RiskSensitivityLevel {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case RiskSensitivityLevel.low:    return 'Low';
      case RiskSensitivityLevel.medium: return 'Medium';
      case RiskSensitivityLevel.high:   return 'High';
    }
  }
}

/// Alert threshold category for Configuration Settings (step 3).
enum AlertThreshold {
  warningLevel,
  criticalLevel;

  String get label {
    switch (this) {
      case AlertThreshold.warningLevel:  return 'Warning Level';
      case AlertThreshold.criticalLevel: return 'Critical Level';
    }
  }
}

/// WHO compliance result for a sensor reading.
enum ComplianceStatus {
  pass,
  fail;

  String get label {
    switch (this) {
      case ComplianceStatus.pass: return 'Pass';
      case ComplianceStatus.fail: return 'Fail';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Value objects
// ─────────────────────────────────────────────────────────────────────────────

/// A single sensor reading snapshot.
class SensorReading {
  final double value;
  final ParameterType parameter;
  final TrendDirection trend;
  final DateTime timestamp;

  const SensorReading({
    required this.value,
    required this.parameter,
    required this.trend,
    required this.timestamp,
  });

  /// Formatted string shown in the card, e.g. "5.2 pH".
  String get displayValue => '$value ${parameter.unit}';
}

/// Structured AI advisory returned for a sensor reading.
class AiAdvisory {
  /// Short headline shown in the sensor card.
  final String headline;
  /// Fuller explanation of the impact category.
  final String impactExplanation;
  /// Bulleted list of concrete actions the operator should take.
  final List<String> recommendedActions;
  /// Regulatory / environmental impact notes.
  final String impactNotes;

  const AiAdvisory({
    required this.headline,
    required this.impactExplanation,
    required this.recommendedActions,
    required this.impactNotes,
  });
}

/// Full sensor entity stored and managed by the repository.
class SensorModel {
  final String id;
  final String name;
  final String location;
  final ParameterType parameter;
  final RiskLevel riskLevel;
  final SensorReading latestReading;
  final ComplianceStatus complianceStatus;
  final AiAdvisory advisory;
  final bool aiAdvisoryEnabled;
  final String? gpsCoordinates;
  final DataSourceType dataSource;
  final RiskSensitivityLevel sensitivityLevel;
  /// Safe operating range, e.g. "6.5 - 6.8"
  final String safeRange;
  final AlertThreshold? alertThreshold;
 
  const SensorModel({
    required this.id,
    required this.name,
    required this.location,
    required this.parameter,
    required this.riskLevel,
    required this.latestReading,
    required this.advisory,
    this.complianceStatus    = ComplianceStatus.pass,
    this.aiAdvisoryEnabled   = true,
    this.gpsCoordinates,
    this.dataSource          = DataSourceType.iot,
    this.sensitivityLevel    = RiskSensitivityLevel.medium,
    this.safeRange           = '',
    this.alertThreshold,
  });


  SensorModel copyWith({
    String? id,
    String? name,
    String? location,
    ParameterType? parameter,
    RiskLevel? riskLevel,
    SensorReading? latestReading,
    AiAdvisory? advisory,
    ComplianceStatus? complianceStatus,
    bool? aiAdvisoryEnabled,
    String? gpsCoordinates,
    DataSourceType? dataSource,
    RiskSensitivityLevel? sensitivityLevel,
    String? safeRange,
    AlertThreshold? alertThreshold,
    bool clearAlertThreshold = false,
  }) {
    return SensorModel(
      id:                id               ?? this.id,
      name:              name             ?? this.name,
      location:          location         ?? this.location,
      parameter:         parameter        ?? this.parameter,
      riskLevel:         riskLevel        ?? this.riskLevel,
      latestReading:     latestReading    ?? this.latestReading,
      advisory:          advisory         ?? this.advisory,
      complianceStatus:  complianceStatus ?? this.complianceStatus,
      aiAdvisoryEnabled: aiAdvisoryEnabled ?? this.aiAdvisoryEnabled,
      gpsCoordinates:    gpsCoordinates   ?? this.gpsCoordinates,
      dataSource:        dataSource       ?? this.dataSource,
      sensitivityLevel:  sensitivityLevel ?? this.sensitivityLevel,
      safeRange:         safeRange        ?? this.safeRange,
      alertThreshold: clearAlertThreshold ? null : (alertThreshold ?? this.alertThreshold),
  
    );
  }
}

class Nullable<T> {
   final T? value;
   const Nullable(this.value);
}

// ─────────────────────────────────────────────────────────────────────────────
// Wizard form — mutable, lives in SensorProvider during the add-sensor flow
// ─────────────────────────────────────────────────────────────────────────────

/// Transient form data built up across the 5-step Add Sensor wizard.
class AddSensorForm {
  // Step 1 — Basic Info
  ParameterType? parameterType;
  String sensorId   = '';
  String sensorName = '';

  // Step 2 — Location & Source
  String site              = '';
  String specificLocation  = '';
  String gpsCoordinates    = '';
  DataSourceType? dataSourceType;

  // Step 3 — Configuration Settings
  String safeRange         = '';
  AlertThreshold? alertThreshold;

  // Step 4 — AI Preferences
  bool aiAdvisoryEnabled         = false;
  RiskSensitivityLevel? sensitivityLevel;

  AddSensorForm();

  bool get step1Valid =>
      parameterType != null && sensorId.isNotEmpty && sensorName.isNotEmpty;

  bool get step2Valid =>
      site.isNotEmpty && specificLocation.isNotEmpty;

  /// Config settings are optional — always valid.
  bool get step3Valid => true;
}

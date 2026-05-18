import '../models/sensor_model.dart';

/// Abstract interface for sensor data operations.
/// Screens depend on this contract — swap [MockSensorRepository] for a
/// real HTTP/Firestore implementation without touching any UI code.
abstract class SensorRepository {
  Future<List<SensorModel>> getSensors();
  Future<SensorModel?> getSensorById(String id);
  Future<SensorModel> addSensor(AddSensorForm form);
  Future<void> deleteSensor(String id);
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock implementation
// ─────────────────────────────────────────────────────────────────────────────

/// In-memory repository pre-seeded with realistic sample sensors.
class MockSensorRepository implements SensorRepository {
  final List<SensorModel> _sensors = [
    SensorModel(
      id:        'AQ-PH-203',
      name:      'pH Sensor Alpha',
      location:  'Amuwo Odofin, Lagos',
      parameter: ParameterType.pH,
      riskLevel: RiskLevel.high,
      complianceStatus: ComplianceStatus.fail,
      safeRange:       '6.5 - 8.5',
      alertThreshold:  AlertThreshold.criticalLevel,
      latestReading: SensorReading(
        value:     7.2,
        parameter: ParameterType.pH,
        trend:     TrendDirection.up,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      advisory: const AiAdvisory(
        headline:          'The pH level is above the acceptable discharge range',
        impactExplanation: 'Effects on compliance, ecosystem or process safety.',
        recommendedActions: [
          'Inspect neutralization system',
          'Verify dosing levels',
          'Monitor readings closely',
        ],
        impactNotes:
            'Continued discharge at this level may lead to regulatory violations.',
      ),
    ),
    SensorModel(
      id:        'AQ-PH-202',
      name:      'pH Sensor Beta',
      location:  'Amuwo Odofin, Lagos',
      parameter: ParameterType.pH,
      riskLevel: RiskLevel.medium,
      complianceStatus: ComplianceStatus.fail,
      safeRange:       '6.5 - 8.5',
      alertThreshold:  AlertThreshold.warningLevel,
      latestReading: SensorReading(
        value:     5.2,
        parameter: ParameterType.pH,
        trend:     TrendDirection.up,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      advisory: const AiAdvisory(
        headline:          'Acidity exceeds safe discharge limits',
        impactExplanation: 'Low pH may corrode infrastructure and harm aquatic life.',
        recommendedActions: [
          'Add alkaline buffer to treatment tank',
          'Check inlet flow composition',
        ],
        impactNotes:
            'Monitor for 30 min; escalate if pH drops below 5.0.',
      ),
    ),    SensorModel(
      id:        'AQ-TUR-145',
      name:      'Turbidity Monitor A',
      location:  'Mowe, Ogun',
      parameter: ParameterType.turbidity,
      riskLevel: RiskLevel.low,
      complianceStatus: ComplianceStatus.pass,
      safeRange:       '0 - 5',
      alertThreshold:  AlertThreshold.warningLevel,
      latestReading: SensorReading(
        value:     2.3,
        parameter: ParameterType.turbidity,
        trend:     TrendDirection.down,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      advisory: const AiAdvisory(
        headline:          'Turbidity within acceptable range.',
        impactExplanation: 'High turbidity reduces UV disinfection effectiveness.',
        recommendedActions: [
          'Run coagulation cycle',
          'Inspect filter media',
        ],
        impactNotes: 'Values trending down — continue monitoring.',
      ),
    ),
    SensorModel(
      id:        'AQ-TUR-146',
      name:      'Turbidity Monitor B',
      location:  'Berger, Lagos',
      parameter: ParameterType.turbidity,
      riskLevel: RiskLevel.low,
      complianceStatus: ComplianceStatus.pass,
      safeRange:       '0 - 5',
      latestReading: SensorReading(
        value:     2.3,
        parameter: ParameterType.turbidity,
        trend:     TrendDirection.down,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      advisory: const AiAdvisory(
        headline:          'Turbidity within acceptable range.',
        impactExplanation: 'Sensor operating within acceptable parameters.',
        recommendedActions: ['Maintain current treatment protocol'],
        impactNotes: 'No immediate action required.',
      ),
      aiAdvisoryEnabled: false,
    ),
  ];

  @override
  Future<List<SensorModel>> getSensors() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_sensors);
  }

  @override
  Future<SensorModel?> getSensorById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _sensors.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<SensorModel> addSensor(AddSensorForm form) async {
    await Future.delayed(const Duration(seconds: 1));
    final sensor = SensorModel(
      id:               form.sensorId,
      name:             form.sensorName,
      location:         '${form.specificLocation}, ${form.site}',
      parameter:        form.parameterType ?? ParameterType.other,
      riskLevel:        RiskLevel.low,
      complianceStatus: ComplianceStatus.pass,
      safeRange:        form.safeRange,
      alertThreshold:   form.alertThreshold,
      latestReading: SensorReading(
        value:     0.0,
        parameter: form.parameterType ?? ParameterType.other,
        trend:     TrendDirection.stable,
        timestamp: DateTime.now(),
      ),
      advisory: const AiAdvisory(
        headline:           'Awaiting first reading.',
        impactExplanation:  'No data yet.',
        recommendedActions: [],
        impactNotes:        '',
      ),
      aiAdvisoryEnabled: form.aiAdvisoryEnabled,
      gpsCoordinates:    form.gpsCoordinates.isNotEmpty ? form.gpsCoordinates : null,
      dataSource:        form.dataSourceType ?? DataSourceType.iot,
      sensitivityLevel:  form.sensitivityLevel ?? RiskSensitivityLevel.medium,
    );
    _sensors.add(sensor);
    return sensor;
  }

  @override
  Future<void> deleteSensor(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _sensors.removeWhere((s) => s.id == id);
  }
}

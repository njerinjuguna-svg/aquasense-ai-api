import 'package:flutter/material.dart';
import '../models/sensor_model.dart';
import '../repositories/sensor_repository.dart';

/// Possible states for any async data load.
enum LoadState { initial, loading, loaded, error }

/// Central state manager for sensors, search, wizard, and editing.
///
/// Search is scoped per-screen via [SensorSearchScope] rather than
/// a single shared query — so typing in the Home search doesn't
/// affect the Sensors tab list and vice versa.
class SensorProvider extends ChangeNotifier {
  final SensorRepository _repository;

  SensorProvider(this._repository);

  // ── Sensor list ───────────────────────────────────────────────────────────

  List<SensorModel> _sensors = [];
  LoadState _loadState       = LoadState.initial;
  String?   _errorMessage;

  List<SensorModel> get sensors      => _sensors;
  LoadState         get loadState    => _loadState;
  String?           get errorMessage => _errorMessage;
  bool              get isLoading    => _loadState == LoadState.loading;

  /// Up to [count] most recent sensors — used by HomeScreen summary.
  List<SensorModel> recentSensors({int count = 3}) =>
      _sensors.take(count).toList();

  Future<void> loadSensors() async {
    _loadState    = LoadState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _sensors   = await _repository.getSensors();
      _loadState = LoadState.loaded;
    } catch (e, st) {
      assert(() { debugPrint('loadSensors error: $e\n$st'); return true; }());
      _loadState    = LoadState.error;
      _errorMessage = 'Failed to load sensors. Please try again.';
    }
    notifyListeners();
  }

  // ── Per-screen search ─────────────────────────────────────────────────────

  /// Independent search query per screen scope.
  /// Keyed by [SensorSearchScope] so Home and Sensors never share state.
  final Map<SensorSearchScope, String> _queries = {};

  /// Update the search query for a given [scope].
  void setSearchQuery(String query, {required SensorSearchScope scope}) {
    _queries[scope] = query.toLowerCase();
    notifyListeners();
  }

  /// Clear the search query for a given [scope].
  void clearSearch({required SensorSearchScope scope}) {
    _queries.remove(scope);
    notifyListeners();
  }

  /// Sensors filtered by the query active in [scope].
  List<SensorModel> filteredSensors({required SensorSearchScope scope}) {
    final q = _queries[scope] ?? '';
    if (q.isEmpty) return _sensors;
    return _sensors.where((s) =>
      s.id.toLowerCase().contains(q)       ||
      s.name.toLowerCase().contains(q)     ||
      s.location.toLowerCase().contains(q) ||
      s.parameter.label.toLowerCase().contains(q),
    ).toList();
  }

  /// Recent sensors optionally filtered by Home scope query.
  List<SensorModel> filteredRecentSensors({int count = 3}) {
    return filteredSensors(scope: SensorSearchScope.home).take(count).toList();
  }

  // ── Edit sensor ───────────────────────────────────────────────────────────

  bool _editLoading = false;
  bool get editLoading => _editLoading;

  /// Updates a sensor in-place and notifies listeners.
  /// In a real app this would call `_repository.updateSensor(form)`.
  Future<bool> updateSensor(SensorModel original, EditSensorForm form) async {
    _editLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800)); // simulate API

      final updated = original.copyWith(
        name:              form.name.isNotEmpty ? form.name : original.name,
        location:          form.location.isNotEmpty ? form.location : original.location,
        safeRange:         form.safeRange,
        alertThreshold:    form.alertThreshold,
        aiAdvisoryEnabled: form.aiAdvisoryEnabled,
        sensitivityLevel:  form.sensitivityLevel,
      );

      final idx = _sensors.indexWhere((s) => s.id == original.id);
      if (idx >= 0) {
        _sensors = List.of(_sensors)..[idx] = updated;
      }

      _editLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _editLoading  = false;
      _errorMessage = 'Failed to update sensor.';
      notifyListeners();
      return false;
    }
  }

  // ── Add Sensor wizard ─────────────────────────────────────────────────────

  static const int totalWizardSteps = 5;
  static const int lastWizardStep   = totalWizardSteps - 1;

  AddSensorForm _form        = AddSensorForm();
  int           _wizardStep  = 0;
  bool          _addingLoading = false;

  AddSensorForm get form          => _form;
  int           get wizardStep    => _wizardStep;
  bool          get addingLoading => _addingLoading;
  bool          get isLastStep    => _wizardStep == lastWizardStep;

  void nextWizardStep() {
    if (_wizardStep < lastWizardStep) { _wizardStep++; notifyListeners(); }
  }

  void prevWizardStep() {
    if (_wizardStep > 0) { _wizardStep--; notifyListeners(); }
  }

  void resetWizard() {
    _form          = AddSensorForm();
    _wizardStep    = 0;
    _addingLoading = false;
    notifyListeners();
  }

  void updateForm() => notifyListeners();

  bool get canAdvance {
    switch (_wizardStep) {
      case 0: return _form.step1Valid;
      case 1: return _form.step2Valid;
      default: return true;
    }
  }

  Future<SensorModel?> submitSensor() async {
    _addingLoading = true;
    notifyListeners();
    try {
      final sensor   = await _repository.addSensor(_form);
      _sensors       = [..._sensors, sensor];
      _loadState     = LoadState.loaded;
      _addingLoading = false;
      notifyListeners();
      return sensor;
    } catch (e, st) {
      assert(() { debugPrint('loadSensors error: $e\n$st'); return true; }());
      _addingLoading = false;
      _errorMessage  = 'Failed to add sensor. Please try again.';
      notifyListeners();
      return null;
}
   
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supporting types
// ─────────────────────────────────────────────────────────────────────────────

/// Identifies which screen owns a search query.
/// Prevents Home and Sensors search from interfering with each other.
enum SensorSearchScope { home, sensors }

/// Mutable form data for the Edit Sensor sheet.
/// Pre-filled from an existing [SensorModel].
class EditSensorForm {
  String name;
  String location;
  String safeRange;
  AlertThreshold? alertThreshold;
  bool aiAdvisoryEnabled;
  RiskSensitivityLevel? sensitivityLevel;

  EditSensorForm({
    required this.name,
    required this.location,
    required this.safeRange,
    required this.alertThreshold,
    required this.aiAdvisoryEnabled,
    required this.sensitivityLevel,
  });

  /// Factory that pre-fills the form from an existing sensor.
  factory EditSensorForm.fromSensor(SensorModel sensor) => EditSensorForm(
    name:              sensor.name,
    location:          sensor.location,
    safeRange:         sensor.safeRange,
    alertThreshold:    sensor.alertThreshold,
    aiAdvisoryEnabled: sensor.aiAdvisoryEnabled,
    sensitivityLevel:  sensor.sensitivityLevel,
  );

  bool get isValid => name.isNotEmpty && location.isNotEmpty;
}

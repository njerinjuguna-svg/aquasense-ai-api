import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sensor_model.dart';
import '../../providers/sensor_provider.dart';
import '../../widgets/common/app_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public entry point
// ─────────────────────────────────────────────────────────────────────────────

/// Shows the 5-step Add Sensor wizard as a modal bottom sheet.
/// Always resets the wizard state before opening.
void showAddSensorSheet(BuildContext context) {
  context.read<SensorProvider>().resetWizard();
  showModalBottomSheet(
    context:             context,
    isScrollControlled:  true,
    backgroundColor:     Colors.transparent,
    builder:             (_) => const _AddSensorSheet(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Root sheet widget
// ─────────────────────────────────────────────────────────────────────────────

class _AddSensorSheet extends StatelessWidget {
  const _AddSensorSheet();

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, provider, _) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize:     0.5,
          maxChildSize:     0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color:        AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  _DragHandle(),
                  _SheetHeader(step: provider.wizardStep),
                  _StepIndicator(
                    currentStep: provider.wizardStep,
                    totalSteps:  SensorProvider.totalWizardSteps,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _stepContent(provider.wizardStep, provider),
                    ),
                  ),
                  _SheetFooter(provider: provider),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _stepContent(int step, SensorProvider provider) {
    switch (step) {
      case 0: return _Step1BasicInfo(form: provider.form, onUpdate: provider.updateForm);
      case 1: return _Step2Location(form: provider.form, onUpdate: provider.updateForm);
      case 2: return _Step3Config(form: provider.form, onUpdate: provider.updateForm);
      case 3: return _Step4AiPrefs(form: provider.form, onUpdate: provider.updateForm);
      case 4: return _Step5Review(form: provider.form);
      default: return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chrome widgets (handle, header, step bar, footer)
// ─────────────────────────────────────────────────────────────────────────────

/// Drag handle pill at the top of the sheet.
class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 40, height: 4,
        decoration: BoxDecoration(
          color:        AppColors.borderColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Sheet title + ✕ close button.
class _SheetHeader extends StatelessWidget {
  final int step;

  static const _titles = [
    'Basic Sensor Information',
    'Location & Source Mapping',
    'Configuration Settings',
    'AI Monitoring Preferences',
    'Review & Confirm Screen',
  ];

  const _SheetHeader({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _titles[step],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close, color: AppColors.textGrey, size: 22),
          ),
        ],
      ),
    );
  }
}

/// Horizontal progress bar — one segment per wizard step.
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: List.generate(totalSteps, (i) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color:        i <= currentStep ? AppColors.teal : AppColors.mintLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Next / Submit / Add Sensor button pinned to the bottom of the sheet.
class _SheetFooter extends StatelessWidget {
  final SensorProvider provider;

  const _SheetFooter({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 12, 24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: AppButton(
        label:     provider.isLastStep ? 'Add Sensor' : 'Next',
        enabled:   provider.canAdvance,
        isLoading: provider.addingLoading,
        onPressed: () => _handleNext(context, provider),
      ),
    );
  }

  Future<void> _handleNext(BuildContext context, SensorProvider provider) async {
    if (!provider.isLastStep) {
      provider.nextWizardStep();
      return;
    }
    // Final step — submit and show success
    final sensor = await provider.submitSensor();
    if (context.mounted) {
      Navigator.of(context).pop();
      if (sensor != null) {
        _showSuccessSheet(context, sensor);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add sensor. Please try again.')),
        );
      }
    }
  }}

// ─────────────────────────────────────────────────────────────────────────────
// Success bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

void _showSuccessSheet(BuildContext context, SensorModel sensor) {
  showModalBottomSheet(
    context:         context,
    backgroundColor: Colors.transparent,
    builder:         (_) => _SuccessSheet(sensorId: sensor.id),
  );
}

class _SuccessSheet extends StatelessWidget {
  final String sensorId;
  const _SuccessSheet({required this.sensorId});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Outer glow ring + teal circle + check
          Container(
            width: 90, height: 90,
            decoration: const BoxDecoration(color: AppColors.mintLight, shape: BoxShape.circle),
            child: Center(
              child: Container(
                width: 72, height: 72,
                decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: AppColors.white, size: 34),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Successful', style: tt.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Sensor $sensorId successfully added and now being monitored.',
            textAlign: TextAlign.center,
            style: tt.bodyMedium,
          ),
          const SizedBox(height: 28),
          AppButton(label: 'Done', onPressed: () => Navigator.of(context).pop()),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wizard steps
// ─────────────────────────────────────────────────────────────────────────────

/// Step 1 — Basic Sensor Information
/// Fields: Parameter Type (dropdown), Sensor ID, Sensor Name
class _Step1BasicInfo extends StatelessWidget {
  final AddSensorForm form;
  final VoidCallback  onUpdate;
  const _Step1BasicInfo({required this.form, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return _StepBody(children: [
      _WizardFieldLabel('Parameter Type'),
      _DropdownField<ParameterType>(
        hint:      'Select Parameter Type',
        value:     form.parameterType,
        items:     ParameterType.values,
        labelOf:   (p) => p.label,
        onChanged: (v) { form.parameterType = v; onUpdate(); },
      ),
      _WizardFieldLabel('Sensor ID'),
      _WizardTextField(
        hint:         'e.g - AQ-PH-206',
        initialValue: form.sensorId,
        onChanged:    (v) { form.sensorId = v; onUpdate(); },
      ),
      _WizardFieldLabel('Sensor Name'),
      _WizardTextField(
        hint:         'Enter Sensor Name',
        initialValue: form.sensorName,
        onChanged:    (v) { form.sensorName = v; onUpdate(); },
      ),
    ]);
  }
}

/// Step 2 — Location & Source Mapping
/// Fields: Site/Facility, Specific Location, GPS Coordinates, Data Source Type
class _Step2Location extends StatelessWidget {
  final AddSensorForm form;
  final VoidCallback  onUpdate;
  const _Step2Location({required this.form, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return _StepBody(children: [
      _WizardFieldLabel('Site/Facility'),
      _WizardTextField(
        hint:         'Select Site',
        initialValue: form.site,
        onChanged:    (v) { form.site = v; onUpdate(); },
      ),
      _WizardFieldLabel('Specific Location'),
      _WizardTextField(
        hint:         'Enter Location',
        initialValue: form.specificLocation,
        onChanged:    (v) { form.specificLocation = v; onUpdate(); },
      ),
      _WizardFieldLabel('GPS Coordinates'),
      _WizardTextField(
        hint:         'GPS Coordinates',
        initialValue: form.gpsCoordinates,
        onChanged:    (v) { form.gpsCoordinates = v; onUpdate(); },
      ),
      _WizardFieldLabel('Data Source Type'),
      _DropdownField<DataSourceType>(
        hint:      'Select Data Source Type',
        value:     form.dataSourceType,
        items:     DataSourceType.values,
        labelOf:   (d) => d.label,
        onChanged: (v) { form.dataSourceType = v; onUpdate(); },
      ),
    ]);
  }
}

/// Step 3 — Configuration Settings  (new step)
/// Fields: Safe Range (min/max text), Alert Thresholds (dropdown)
class _Step3Config extends StatelessWidget {
  final AddSensorForm form;
  final VoidCallback  onUpdate;
  const _Step3Config({required this.form, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return _StepBody(children: [
      _WizardFieldLabel('Safe Range (Min/Max values)'),
      _WizardTextField(
        hint:         'e.g. 6.5 - 8.5',
        initialValue: form.safeRange,
        onChanged:    (v) { form.safeRange = v; onUpdate(); },
      ),
      _WizardFieldLabel('Alert Thresholds'),
      _DropdownField<AlertThreshold>(
        hint:      'Select Threshold',
        value:     form.alertThreshold,
        items:     AlertThreshold.values,
        labelOf:   (a) => a.label,
        onChanged: (v) { form.alertThreshold = v; onUpdate(); },
      ),
    ]);
  }
}

/// Step 4 — AI Monitoring Preferences
/// Fields: Enable AI Advisory toggle, Risk Sensitivity Level
class _Step4AiPrefs extends StatelessWidget {
  final AddSensorForm form;
  final VoidCallback  onUpdate;
  const _Step4AiPrefs({required this.form, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return _StepBody(children: [
      _AiAdvisoryToggle(
        value:     form.aiAdvisoryEnabled,
        onChanged: (v) { form.aiAdvisoryEnabled = v; onUpdate(); },
      ),
      _WizardFieldLabel('Risk Sensitivity Level'),
      _DropdownField<RiskSensitivityLevel>(
        hint:      'Enter Sensitivity Level',
        value:     form.sensitivityLevel,
        items:     RiskSensitivityLevel.values,
        labelOf:   (r) => r.label,
        onChanged: (v) { form.sensitivityLevel = v; onUpdate(); },
      ),
    ]);
  }
}

/// Step 5 — Review & Confirm (read-only summary)
class _Step5Review extends StatelessWidget {
  final AddSensorForm form;
  const _Step5Review({required this.form});

  @override
  Widget build(BuildContext context) {
    return _StepBody(children: [
      _ReviewRow(label: 'Sensor ID',   value: form.sensorId),
      _ReviewRow(label: 'Parameter',   value: form.parameterType?.label ?? '—'),
      _ReviewRow(
        label: 'Location',
        value: [form.specificLocation, form.site]
            .where((s) => s.isNotEmpty)
            .join(', '),
      ),
      _ReviewRow(label: 'Safe Range',  value: form.safeRange.isNotEmpty ? form.safeRange : '—'),
      _ReviewRow(label: 'Thresholds',  value: form.alertThreshold?.label ?? '—'),
      _AiAdvisoryToggle(
        value:     form.aiAdvisoryEnabled,
        onChanged: null, // read-only on review
      ),
    ]);  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable wizard sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps step content in consistent vertical spacing.
class _StepBody extends StatelessWidget {
  final List<Widget> children;
  const _StepBody({required this.children});

  @override
  Widget build(BuildContext context) {
    final spaced = <Widget>[const SizedBox(height: 16)];
    for (final child in children) {
      spaced.add(child);
      spaced.add(const SizedBox(height: 16));
    }
    spaced.add(const SizedBox(height: 8)); // extra bottom breathing room
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: spaced);
  }
}

/// Bold label above a wizard field — uses [TextTheme.labelLarge].
class _WizardFieldLabel extends StatelessWidget {
  final String text;
  const _WizardFieldLabel(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.labelLarge);
}

/// Text input that inherits decoration entirely from [AppTheme.inputDecorationTheme].
class _WizardTextField extends StatelessWidget {
  final String              hint;
  final String              initialValue;
  final ValueChanged<String> onChanged;
  final TextInputType       keyboardType;

  const _WizardTextField({
    required this.hint,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue.isNotEmpty ? initialValue : null,
      onChanged:    onChanged,
      keyboardType: keyboardType,
      style:        Theme.of(context).textTheme.bodyLarge,
      decoration:   InputDecoration(hintText: hint),
    );
  }
}

/// Generic enum dropdown — no raw hex, no fontSize literals.
class _DropdownField<T> extends StatelessWidget {
  final String         hint;
  final T?             value;
  final List<T>        items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: AppColors.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value:      value,
          hint:       Text(hint, style: tt.bodyMedium),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey),
          items: items.map((item) => DropdownMenuItem<T>(
            value: item,
            child: Text(labelOf(item), style: tt.bodyLarge),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// "Enable AI Advisory" row with a teal checkbox.
/// Pass [onChanged] as null to render in read-only (review) mode.
class _AiAdvisoryToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _AiAdvisoryToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
     return Semantics(
        label: 'Enable AI Advisory',
        checked: value,
        enabled: onChanged != null,
      child:GestureDetector(
        onTap: onChanged != null ? () => onChanged!(!value) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color:        AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border:       Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Enable AI Advisory', style: Theme.of(context).textTheme.bodyLarge),
              _TealCheckbox(checked: value),
            ],
          ),
      ),
    ),
    );
  }
}

/// Small teal-branded checkbox square.
class _TealCheckbox extends StatelessWidget {
  final bool checked;
  const _TealCheckbox({required this.checked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  20,
      height: 20,
      decoration: BoxDecoration(
        color:        checked ? AppColors.teal.withValues(alpha: 0.12) : AppColors.white,
        border: Border.all(
          color: checked ? AppColors.teal : AppColors.borderColor,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: checked
          ? const Icon(Icons.check, size: 13, color: AppColors.teal)
          : null,
    );
  }
}

/// Read-only labelled field shown in the Review step.
class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tt.labelLarge),
        const SizedBox(height: 6),
        Container(
          width:   double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color:        AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border:       Border.all(color: AppColors.borderColor),
          ),
          child: Text(value.isNotEmpty ? value : '—', style: tt.bodyMedium),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sensor_model.dart';
import '../../providers/sensor_provider.dart';
import '../../widgets/common/app_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public entry point
// ─────────────────────────────────────────────────────────────────────────────

/// Shows the Edit Sensor bottom sheet pre-filled from [sensor].
/// On success the sensor list is updated in-place via [SensorProvider].
void showEditSensorSheet(BuildContext context, SensorModel sensor) {
  showModalBottomSheet(
    context:             context,
    isScrollControlled:  true,
    backgroundColor:     Colors.transparent,
    builder:             (_) => _EditSensorSheet(sensor: sensor),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Root sheet
// ─────────────────────────────────────────────────────────────────────────────

class _EditSensorSheet extends StatefulWidget {
  final SensorModel sensor;
  const _EditSensorSheet({required this.sensor});

  @override
  State<_EditSensorSheet> createState() => _EditSensorSheetState();
}

class _EditSensorSheetState extends State<_EditSensorSheet> {
  late final EditSensorForm _form;

  @override
  void initState() {
    super.initState();
    // Pre-fill every field from the existing sensor
    _form = EditSensorForm.fromSensor(widget.sensor);
  }

  void _update() => setState(() {});

  Future<void> _submit() async {
    final provider = context.read<SensorProvider>();
    final success  = await provider.updateSensor(widget.sensor, _form);
    if (success && mounted) {
      Navigator.of(context).pop();
      _showSuccessSnack(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
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
              // Drag handle
              _DragHandle(),

              // Header: title + close button
              _SheetHeader(
                title:   'Edit Sensor',
                onClose: () => Navigator.of(context).pop(),
              ),

              // Scrollable form body
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _EditForm(form: _form, sensor: widget.sensor, onUpdate: _update),
                ),
              ),

              // Save button pinned at bottom
              _Footer(
                enabled:   _form.isValid,
                isLoading: provider.editLoading,
                onSave:    _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}

void _showSuccessSnack(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Sensor updated successfully'),
      backgroundColor: AppColors.teal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Chrome: drag handle, header, footer
// ─────────────────────────────────────────────────────────────────────────────

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

class _SheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  const _SheetHeader({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style:     Theme.of(context).textTheme.titleMedium,
            ),
          ),
          GestureDetector(
            onTap:  onClose,
            child:  const Icon(Icons.close, color: AppColors.textGrey, size: 22),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onSave;
  const _Footer({required this.enabled, required this.isLoading, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 12, 24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: AppButton(
        label:     'Save Changes',
        enabled:   enabled,
        isLoading: isLoading,
        onPressed: onSave,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form body
// ─────────────────────────────────────────────────────────────────────────────

/// All editable fields rendered in a single scrollable column.
/// Read-only fields (Sensor ID, Parameter) are shown greyed out.
class _EditForm extends StatelessWidget {
  final EditSensorForm form;
  final SensorModel    sensor;
  final VoidCallback   onUpdate;
  const _EditForm({required this.form, required this.sensor, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // ── Read-only section header ───────────────────────────────────
        _SectionHeader('Sensor Info'),
        const SizedBox(height: 12),

        // Sensor ID — read-only (ID is immutable after creation)
        _EditFieldLabel('Sensor ID'),
        const SizedBox(height: 8),
        _ReadOnlyField(value: sensor.id),
        const SizedBox(height: 16),

        // Parameter type — read-only (changing type would invalidate data)
        _EditFieldLabel('Parameter Type'),
        const SizedBox(height: 8),
        _ReadOnlyField(value: sensor.parameter.label),
        const SizedBox(height: 24),

        // ── Editable fields ────────────────────────────────────────────
        _SectionHeader('Location'),
        const SizedBox(height: 12),

        _EditFieldLabel('Sensor Name'),
        const SizedBox(height: 8),
        _EditTextField(
          initialValue: form.name,
          hint:         'Sensor Name',
          onChanged:    (v) { form.name = v; onUpdate(); },
        ),
        const SizedBox(height: 16),

        _EditFieldLabel('Location'),
        const SizedBox(height: 8),
        _EditTextField(
          initialValue: form.location,
          hint:         'Location',
          onChanged:    (v) { form.location = v; onUpdate(); },
        ),
        const SizedBox(height: 24),

        _SectionHeader('Configuration'),
        const SizedBox(height: 12),

        _EditFieldLabel('Safe Range (Min/Max)'),
        const SizedBox(height: 8),
        _EditTextField(
          initialValue: form.safeRange,
          hint:         'e.g. 6.5 - 8.5',
          onChanged:    (v) { form.safeRange = v; onUpdate(); },
        ),
        const SizedBox(height: 16),

        _EditFieldLabel('Alert Threshold'),
        const SizedBox(height: 8),
        _EnumDropdown<AlertThreshold>(
          hint:      'Select Threshold',
          value:     form.alertThreshold,
          items:     AlertThreshold.values,
          labelOf:   (a) => a.label,
          onChanged: (v) { form.alertThreshold = v; onUpdate(); },
        ),
        const SizedBox(height: 24),

        _SectionHeader('AI Preferences'),
        const SizedBox(height: 12),

        _AiAdvisoryToggle(
          value:     form.aiAdvisoryEnabled,
          onChanged: (v) { form.aiAdvisoryEnabled = v; onUpdate(); },
        ),
        const SizedBox(height: 16),

        _EditFieldLabel('Risk Sensitivity Level'),
        const SizedBox(height: 8),
        _EnumDropdown<RiskSensitivityLevel>(
          hint:      'Select Sensitivity Level',
          value:     form.sensitivityLevel,
          items:     RiskSensitivityLevel.values,
          labelOf:   (r) => r.label,
          onChanged: (v) { form.sensitivityLevel = v; onUpdate(); },
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable edit-sheet sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Grey divider with a label — separates form sections visually.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(title, style: tt.titleSmall?.copyWith(color: AppColors.textDark)),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: AppColors.borderColor, height: 1)),
      ],
    );
  }
}

/// Bold label above each edit field.
class _EditFieldLabel extends StatelessWidget {
  final String text;
  const _EditFieldLabel(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.labelLarge);
}

/// Editable text input inheriting decoration from theme.
class _EditTextField extends StatelessWidget {
  final String initialValue;
  final String hint;
  final ValueChanged<String> onChanged;

  const _EditTextField({
    required this.initialValue,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged:    onChanged,
      style:        Theme.of(context).textTheme.bodyLarge,
      decoration:   InputDecoration(hintText: hint),
    );
  }
}

/// Greyed-out read-only display field — makes immutable values visible
/// without offering an editable text cursor.
class _ReadOnlyField extends StatelessWidget {
  final String value;
  const _ReadOnlyField({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color:        AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: AppColors.borderColor),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textGrey,
        ),
      ),
    );
  }
}

/// Generic enum dropdown — same pattern as the wizard.
class _EnumDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;

  const _EnumDropdown({
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

/// "Enable AI Advisory" checkbox row — same style as the wizard.
class _AiAdvisoryToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _AiAdvisoryToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
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
    );
  }
}

class _TealCheckbox extends StatelessWidget {
  final bool checked;
  const _TealCheckbox({required this.checked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        color: checked ? AppColors.teal.withValues(alpha: 0.12) : AppColors.white,
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

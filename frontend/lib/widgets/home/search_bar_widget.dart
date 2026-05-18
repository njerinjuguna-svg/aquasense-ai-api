
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Search bar used on Home, Sensors, and Sensor Detail screens.
///
/// Stateful so it owns a [TextEditingController], which enables:
///   - Programmatic clearing via [SearchBarController] (exposed through [controller])
///   - A live ✕ clear button when the field has text
///   - Correct cursor placement after clearing
///
/// Decoration is the grey-surface style that differs from auth fields —
/// see [AppTheme.inputDecorationTheme] comment for reasoning.
class SearchBarWidget extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  /// Optional external controller — pass one to clear the field from outside.
  final SearchBarController? controller;

  const SearchBarWidget({
    super.key,
    this.hint = 'Search sensor or parameter',
    this.onChanged,
    this.onFilterTap,
    this.controller,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    // Allow the parent to trigger a clear via SearchBarController
    widget.controller?._attach(_textController, _onClear);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onClear() {
    _textController.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _textController,
            builder: (_, value, __) {
              return TextField(
                controller: _textController,
                onChanged:  widget.onChanged,
                style:      tt.bodyMedium?.copyWith(color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText:       widget.hint,
                  fillColor:      AppColors.surfaceGrey,
                  // Grey-surface search bar uses borderless style
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:   BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:   BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:   const BorderSide(color: AppColors.teal, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  prefixIcon: const Icon(
                    Icons.search, color: AppColors.textGrey, size: 20,
                  ),
                  // Show ✕ only when there is text
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close, color: AppColors.textGrey, size: 18,
                          ),
                          onPressed: _onClear,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        _FilterButton(onTap: widget.onFilterTap),
      ],
    );
  }
}

/// Companion controller that lets a parent widget clear [SearchBarWidget].
///
/// Usage:
/// ```dart
/// final _searchController = SearchBarController();
/// SearchBarWidget(controller: _searchController, ...)
/// // later:
/// _searchController.clear();
/// ```
class SearchBarController {
  TextEditingController? _textController;
  VoidCallback?          _clearCallback;

  void _attach(TextEditingController tc, VoidCallback clear) {
    _textController = tc;
    _clearCallback  = clear;
  }

  /// Clears the search field and notifies the [onChanged] listener.
  void clear() => _clearCallback?.call();

  void dispose() {
    _textController = null;
    _clearCallback  = null;
  }
}

/// Square filter icon button matching search bar surface.
class _FilterButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _FilterButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color:        AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.tune, color: AppColors.textGrey, size: 20),
      ),
    );
  }
}

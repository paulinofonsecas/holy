part of 'multiversion_cubit.dart';

class MultiversionState extends Equatable {
  final bool isEnabled;
  final List<String> panelIds;

  /// Maps each panel ID to its accent colour. Panels that do not appear in
  /// this map fall back to [AppThemeColors.defaultPrimaryColor].
  final Map<String, Color> panelColors;

  const MultiversionState({
    required this.isEnabled,
    required this.panelIds,
    this.panelColors = const {},
  });

  MultiversionState copyWith({
    bool? isEnabled,
    List<String>? panelIds,
    Map<String, Color>? panelColors,
  }) {
    return MultiversionState(
      isEnabled: isEnabled ?? this.isEnabled,
      panelIds: panelIds ?? this.panelIds,
      panelColors: panelColors ?? this.panelColors,
    );
  }

  @override
  List<Object> get props => [isEnabled, panelIds, panelColors];
}

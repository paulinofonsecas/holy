part of 'multiversion_cubit.dart';

class MultiversionState extends Equatable {
  final bool isEnabled;
  final List<String> panelIds;

  /// Maps each panel ID to its accent colour. Panels that do not appear in
  /// this map fall back to [AppThemeColors.defaultPrimaryColor].
  final Map<String, Color> panelColors;

  /// Keeps track of the current reading position and config of each active panel.
  final Map<String, PanelConfig> panelConfigs;

  /// Saved study sessions.
  final List<MultiversionSession> savedSessions;

  /// Whether the left sessions sidebar is visible.
  final bool showSessionsSidebar;

  const MultiversionState({
    required this.isEnabled,
    required this.panelIds,
    this.panelColors = const {},
    this.panelConfigs = const {},
    this.savedSessions = const [],
    this.showSessionsSidebar = true,
  });

  MultiversionState copyWith({
    bool? isEnabled,
    List<String>? panelIds,
    Map<String, Color>? panelColors,
    Map<String, PanelConfig>? panelConfigs,
    List<MultiversionSession>? savedSessions,
    bool? showSessionsSidebar,
  }) {
    return MultiversionState(
      isEnabled: isEnabled ?? this.isEnabled,
      panelIds: panelIds ?? this.panelIds,
      panelColors: panelColors ?? this.panelColors,
      panelConfigs: panelConfigs ?? this.panelConfigs,
      savedSessions: savedSessions ?? this.savedSessions,
      showSessionsSidebar: showSessionsSidebar ?? this.showSessionsSidebar,
    );
  }

  @override
  List<Object> get props => [
        isEnabled,
        panelIds,
        panelColors,
        panelConfigs,
        savedSessions,
        showSessionsSidebar,
      ];
}

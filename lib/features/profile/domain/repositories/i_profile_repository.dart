abstract class IProfileRepository {
  /// Gets the saved accent color hex string.
  Future<String?> getAccentColor();

  /// Saves a new accent color hex string.
  Future<void> setAccentColor(String colorHex);
}

import "dart:convert";
import "dart:io";

class UserConfig {
  UserConfig(this.settings);

  Map<String, dynamic> settings;

  factory UserConfig.loadFromFile(String settingsFile) {
    var userSettingsFile = File(settingsFile);
    if (userSettingsFile.existsSync()) {
      String settingsFileString = userSettingsFile.readAsStringSync();
      Map<String, dynamic> settingsFileMap = jsonDecode(settingsFileString);
      return UserConfig(settingsFileMap);
    }

    throw Exception("Settings file '${userSettingsFile.path}' does not exist");
  }

  operator [](Object setting) {
    if (setting is String) {
      if (settings.keys.contains(setting)) {
        return settings[setting];
      } else {
        return {};
      }
    } else {
      throw Exception("Invalid object - ${setting.runtimeType.toString()}");
    }
  }
}

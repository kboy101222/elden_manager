import "dart:convert";

class JsonConfig {
  JsonConfig({
    required this.eldenRingInstallLocation,
    required this.modEngine3InstallLocation,
    this.isDebugMode = false,
    this.debugString = "",
  });

  final String eldenRingInstallLocation;
  final String modEngine3InstallLocation;
  final bool isDebugMode;
  final String debugString;

  factory JsonConfig.fromJson(String jsonString) {
    final Map<String, dynamic> data = json.decode(jsonString);
    return JsonConfig(
      eldenRingInstallLocation: data["eldenRingInstallLocation"],
      modEngine3InstallLocation: data["modEngine3InstallLocation"],
      isDebugMode: data["isDebugMode"],
      debugString: data["debugString"],
    );
  }
}

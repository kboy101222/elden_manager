import "dart:convert";

class JsonConfig {
  JsonConfig({this.isDebugMode = false, this.debugString = ""});

  final bool isDebugMode;
  final String debugString;

  factory JsonConfig.fromJson(String jsonString) {
    final Map<String, dynamic> data = json.decode(jsonString);
    return JsonConfig(
      isDebugMode: data["isDebugMode"],
      debugString: data["debugString"],
    );
  }
}

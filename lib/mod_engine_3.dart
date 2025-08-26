import 'dart:convert';
import 'dart:io';

import 'package:elden_manager/custom_styles.dart';
import 'package:elden_manager/launcher.dart';
import 'package:elden_manager/model_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:version/version.dart';

class ModEngine3 {
  bool? _isInstalled;
  bool? _hasUpdate;
  Map<String, String?> _versionData = {
    "currentVersion": null,
    "latestVersion": null,
    "updateUrl": null,
  };

  Future<bool> get isInstalled async {
    print("Checking if ME3 is installed");
    // if (_isInstalled != null) {
    //   print("Already checked, returning _isInstalled");
    //   return _isInstalled!;
    // }
    await Process.run('me3', ['-V']).then((value) {
      List processedLines = value.stdout.toString().trim().split(" ");
      print("[isInstalled] 'me3 -V' output: $processedLines");
      if (processedLines.length == 2) {
        print("ME3 is Installed!");
        _isInstalled = true;
        // return _isInstalled;
      } else {
        print("ME3 Not Installed!");
        _isInstalled = false;
        // return _isInstalled;
      }
    });
    // _isInstalled = false;
    return _isInstalled!;
  }

  Future<String> get currentVersion async {
    print("Obtaininig Current Version");
    if (_versionData["currentVersion"] != null) {
      print("Already set to ${_versionData["currentVersion"]}");
      return _versionData["currentVersion"]!;
    }

    if (await isInstalled) {
      await Process.run('me3', ['-V']).then((value) async {
        List processedLines = value.stdout.toString().trim().split(" ");
        print("[currentVersion] processedLines: $processedLines");
        String vNumber = processedLines[1].toString();
        print("Obtained version number $vNumber");
        _versionData["currentVersion"] = vNumber;
        return _versionData["currentVersion"];
      });
    } else {
      return "Not Installed";
    }
    return _versionData["currentVersion"]!;
  }

  Future<String> get latestVersion async {
    if (_versionData["latestVersion"] != null) {
      return _versionData["latestVersion"]!;
    }
    await fetchVersionInfo();
    return _versionData["latestVersion"]!;
  }

  Future<String> get updateUrl async {
    if (_versionData["updateUrl"] != null) {
      return _versionData["updateUrl"]!;
    }
    await fetchVersionInfo();
    return _versionData["updateUrl"]!;
  }

  Future<bool> get hasUpdate async {
    await fetchVersionInfo().then((value) async {
      String cVersion = await currentVersion;
      String lVersion = await latestVersion;
      print("currentVersion: $cVersion");
      print("latestVersion: $lVersion");
      try {
        _hasUpdate =
            (Version.parse(lVersion.toString()) >
            Version.parse(cVersion.toString()));
        print("ME3 has update: $_hasUpdate");
        return _hasUpdate;
      } on FormatException {
        print("Error obtaining current version!");
        return false;
      }
    });
    return _hasUpdate!;
  }

  Future<Map<String, String?>> fetchVersionInfo() async {
    // checks if any values in _versionData are null and returns _versionData if they aren't
    bool foundNull = false;
    for (var key in _versionData.keys) {
      if (_versionData[key] == null) foundNull = true;
    }
    if (!foundNull) {
      print("_versionData already set, returning");
      print("$_versionData");
      return _versionData;
    }

    _versionData["currentVersion"] = await currentVersion;

    final response = await http.get(
      Uri.https("api.github.com", "repos/garyttierney/me3/releases/latest"),
    );

    switch (response.statusCode) {
      case 200:
        var content = jsonDecode(response.body);
        String latestVersion = content["name"].toString().trim().replaceAll(
          "v",
          "",
        );
        _versionData["latestVersion"] = latestVersion;
        _versionData["updateUrl"] = content["html_url"];
        return _versionData;
      default:
        _versionData["latestVersion"] = "unknown";
        _versionData["updateUrl"] = "https://github.com";
        throw Exception("${response.statusCode} error from GitHub");
    }
  }
}

Future<UpdateBar> createUpdateBar(ModEngine3 modEngine) async {
  await modEngine.fetchVersionInfo();
  return await UpdateBar.fromModEngineObjectAsync(modEngine);
}

class UpdateBar extends StatelessWidget {
  const UpdateBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 1.0,
      color: Theme.of(context).colorScheme.primary,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: Consumer<ModManagerModel>(
          builder: (context, data, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: children,
            );
          },
        ),
      ),
    );
  }

  static Future<UpdateBar> fromModEngineObjectAsync(
    ModEngine3 modEngine,
  ) async {
    bool isInstalled = await modEngine.isInstalled;
    print("isInstalled: $isInstalled");
    bool hasUpdate = await modEngine.hasUpdate;
    String currentVersion = await modEngine.currentVersion;
    String latestVersion = await modEngine.latestVersion;
    String updateUrl = await modEngine.updateUrl;

    if (!isInstalled) {
      return UpdateBar(
        children: [
          Launcher(
            url: Uri.parse((updateUrl)),
            label: "Click here to install ModEngine3",
          ),
        ],
      );
    } else if (isInstalled && hasUpdate) {
      return UpdateBar(
        children: [
          Text(
            "Current ME3 Version: ${currentVersion}",
            style: CustomStyle.mediumWhiteText,
          ),
          Text(
            "Latest ME3 Version: ${latestVersion}",
            style: CustomStyle.mediumWhiteText,
          ),
          Launcher(
            url: Uri.parse(updateUrl),
            label: "Click here to update ModEngine3",
          ),
        ],
      );
    } else {
      return UpdateBar(
        children: [
          Text(
            "Current ME3 Version: ${currentVersion}",
            style: CustomStyle.mediumWhiteText,
          ),
          Text(
            "Latest ME3 Version: ${latestVersion}",
            style: CustomStyle.mediumWhiteText,
          ),
          Icon(Icons.check_circle),
        ],
      );
    }
  }
}

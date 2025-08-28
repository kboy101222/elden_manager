import 'package:elden_manager/json_config.dart';
import 'package:elden_manager/mod.dart';
import 'package:elden_manager/profile/profile.dart';
import 'package:flutter/material.dart';

class ModManagerModel extends ChangeNotifier {
  ModManagerModel({this.model});
  ModManagerModel? model;

  Profile? currentProfile;
  ProfileList profileList = getProfiles("data/profiles");

  ModList? currentModList;
  List<ModTile>? modTileList;

  final UserConfig _settings = UserConfig.loadFromFile(
    "data/settings/user_settings.json",
  );
  UserConfig get settings => _settings;
  List<String> get settingKeys => settings.settings.keys.toList();

  void setCurrentProfile(Profile profile) {
    if (profileList.profiles.contains(profile)) {
      currentProfile = profile;
      currentModList = profile.modList ?? ModList();
      modTileList = buildModListTiles(currentModList!, this);
      notifyListeners();
    }
  }

  dynamic getSetting(String settingKey) {
    if (settingKeys.contains(settingKey)) {
      return settings[settingKey];
    } else {
      return null;
    }
  }

  void toggleMod(Mod mod) {
    if (currentModList != null) {
      currentModList!.toggleMod(mod);
      currentProfile!.saveProfile();
      notifyListeners();
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:elden_manager/mod.dart';

class Profile {
  Profile({
    required this.name,
    this.description = "",
    this.image = "data/images/elden_ring_icon.png",
    required this.fileName,
    this.modList,
  });

  String name;
  String description;
  String image;
  String fileName;
  ModList? modList;

  factory Profile.fromJson(
    Map<String, dynamic> profileInfo, {
    String folderName = "",
    String? imageFile,
    // List<Map>? modList,
  }) {
    for (String key in ["name", "modList"]) {
      if (!profileInfo.keys.contains(key)) {
        throw Exception("Invalid profile JSON. Does not contain key $key");
      }
    }
    String description = profileInfo.keys.contains("description")
        ? profileInfo["description"]
        : "";

    ModList mods = ModList();
    // List<Map> profileMods = jsonDecode(profileInfo["modList"]["modList"]);
    for (var mod in profileInfo["modList"]) {
      mods.add(
        Mod(
          name: mod["name"],
          description: mod["description"],
          isEnabled: mod["isEnabled"] ?? true,
        ),
      );
    }

    if (imageFile != null) {
      return Profile(
        name: profileInfo["name"],
        fileName: folderName,
        description: description,
        image: imageFile,
        modList: mods,
      );
    } else {
      return Profile(
        name: profileInfo["name"],
        fileName: folderName,
        modList: mods,
        description: description,
      );
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> profileMap = {
      "name": name,
      "description": description,
      "image": image,
      "modList": modList != null ? modList!.toJson() : [],
    };
    return profileMap;
  }

  void saveProfile() {
    File profileFile = File("${fileName}/profile.json");
    profileFile.writeAsStringSync(jsonEncode(toJson()));
  }

  @override
  String toString() {
    return "Profile $name";
  }

  @override
  bool operator ==(Object other) {
    if (other is Profile &&
        name == other.name &&
        description == other.description &&
        hashCode == other.hashCode) {
      return true;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(name, description, fileName);
}

class ProfileList {
  ProfileList();

  List<Profile> list = [];
  List<Profile> get profiles {
    return list;
  }

  // ignore: prefer_final_fields
  List<String> _profileNames = [];
  List<String> get profileNames {
    if (_profileNames.isEmpty || list.length > _profileNames.length) {
      _profileNames = [];
      for (Profile profile in list) {
        _profileNames.add(profile.name);
      }
    }
    return _profileNames;
  }

  Profile getProfileByName(String name) {
    for (Profile profile in profiles) {
      if (profile.name == name) {
        return profile;
      }
    }
    throw Exception("No profile found with name '$name'");
  }

  void add(Profile profile) {
    list.add(profile);
  }

  bool remove(Profile profile) {
    return list.remove(profile);
  }

  operator [](Object profile) {
    if (profile is Profile) {
      if (profiles.contains(profile)) {
        return profile;
      }
    } else if (profile is String) {
      try {
        return getProfileByName(profile);
      } on Exception {
        return null;
      }
    }
    throw Exception("The supplied profile does not exist");
  }

  @override
  String toString() {
    return profiles.toString();
  }
}

ProfileList getProfiles(String profilesFolder) {
  if (Directory(profilesFolder).existsSync()) {
    ProfileList profileList = ProfileList();
    var profileFoldersList = Directory(profilesFolder).listSync();
    for (var profileFolder in profileFoldersList) {
      String profileFolderClean = profileFolder.path.replaceAll("'", "");

      var profileFile = jsonDecode(
        File("$profileFolderClean/profile.json").readAsStringSync(),
      );
      String? imageFile;
      if (File("$profileFolderClean/profile_image.png").existsSync()) {
        imageFile = "$profileFolderClean/profile_image.png";
      }
      try {
        Profile profileObj = Profile.fromJson(
          profileFile,
          folderName: profileFolder.path,
          imageFile: imageFile,
        );
        profileList.add(profileObj);
      } on Exception {
        continue;
      }
    }
    return profileList;
  }
  throw Exception("Profile folder not found!");
}

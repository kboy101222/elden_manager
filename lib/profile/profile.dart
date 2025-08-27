import 'dart:convert';
import 'dart:io';

class Profile {
  Profile({
    required this.name,
    this.description = "",
    this.image = "config/images/elden_ring_icon.png",
    required this.fileName,
    required this.modList,
  });

  String name;
  String description;
  String image;
  String fileName;
  List<String> modList;

  factory Profile.fromJson(
    Map<String, dynamic> profileInfo, {
    String folderName = "",
    String? imageFile,
  }) {
    for (String key in ["name", "modList"]) {
      if (!profileInfo.keys.contains(key)) {
        throw Exception("Invalid profile JSON. Does not contain key $key");
      }
    }
    String description = profileInfo.keys.contains("description")
        ? profileInfo["description"]
        : "";
    List<String> modList = [];
    for (var item in profileInfo["modList"]) {
      modList.add(item.toString());
    }
    if (imageFile != null) {
      return Profile(
        name: profileInfo["name"],
        fileName: folderName,
        modList: modList,
        description: description,
        image: imageFile,
      );
    } else {
      return Profile(
        name: profileInfo["name"],
        fileName: folderName,
        modList: modList,
        description: description,
      );
    }
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

  void add(Profile profile) {
    list.add(profile);
  }

  bool remove(Profile profile) {
    return list.remove(profile);
  }

  operator [](Profile profile) {
    if (profiles.contains(profile)) {
      return profile;
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

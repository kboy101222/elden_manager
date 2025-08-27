import 'package:elden_manager/profile/profile.dart';
import 'package:flutter/material.dart';

class ModManagerModel extends ChangeNotifier {
  Profile? currentProfile;
  ProfileList profiles = getProfiles("config/profiles");

  void setCurrentProfile(Profile profile) {
    if (profiles.profiles.contains(profile)) {
      currentProfile = profile;
      notifyListeners();
    }
  }
}

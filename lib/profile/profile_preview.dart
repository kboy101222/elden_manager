import 'dart:convert';
import 'dart:io';

import 'package:elden_manager/profile/profile.dart';
import 'package:flutter/material.dart';
import '../model_manager.dart';

class ProfilePreview extends StatefulWidget {
  const ProfilePreview({
    super.key,
    required this.name,
    required this.description,
    required this.profile,
    this.image = "config/images/elden_ring_icon.png",
    this.notifier,
    this.scaffoldKey,
  });

  final String name;
  final String description;
  final String image;
  final Profile profile;
  final ModManagerModel? notifier;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<ProfilePreview> createState() => _ProfilePreviewState();
}

class _ProfilePreviewState extends State<ProfilePreview> {
  @override
  Widget build(BuildContext context) {
    final Text descriptionElement = widget.description == ""
        ? Text(
            "No description provided",
            style: TextStyle(fontStyle: FontStyle.italic),
          )
        : Text(widget.description);
    return ListTile(
      isThreeLine: true,
      leading: CircleAvatar(backgroundImage: FileImage(File(widget.image))),
      title: Text(widget.name, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: descriptionElement,
      trailing: IconButton(
        onPressed: () {
          if (widget.notifier != null && widget.scaffoldKey != null) {
            widget.notifier?.setCurrentProfile(widget.profile);
            // widget.scaffoldKey?.currentState!.closeDrawer();
          }
        },
        icon: Icon(Icons.play_arrow_outlined),
        tooltip: "Load Profile",
      ),
    );
  }
}

class ProfilePreviewList extends StatefulWidget {
  const ProfilePreviewList({
    super.key,
    required this.children,
    this.notifier,
    required this.scaffoldKey,
  });

  final List<ProfilePreview> children;
  final ModManagerModel? notifier;
  final GlobalKey<ScaffoldState> scaffoldKey;

  static Future<ProfilePreviewList> fromProfileList(
    ProfileList profileList,
    ModManagerModel? notifier,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) async {
    print("scaffoldKey on fromProfileList: $scaffoldKey");
    List<ProfilePreview> elementList = [];

    for (Profile profile in profileList.profiles) {
      elementList.add(
        ProfilePreview(
          name: profile.name,
          description: profile.description,
          image: profile.image,
          notifier: notifier,
          profile: profile,
          scaffoldKey: scaffoldKey,
        ),
      );
    }

    return ProfilePreviewList(scaffoldKey: scaffoldKey, children: elementList);
  }

  @override
  State<ProfilePreviewList> createState() => _ProfilePreviewListState();
}

class _ProfilePreviewListState extends State<ProfilePreviewList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: Text(
            "Profiles",
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
          ),
        ),
        for (ProfilePreview item in widget.children) item,
      ],
    );
  }
}

Future<ProfilePreviewList> createProfilePreviewList(
  String profilesFolder,
  ModManagerModel notifier,
  GlobalKey<ScaffoldState> scaffoldKey,
) async {
  ProfileList profileList = getProfiles(profilesFolder);
  print(profileList);
  return await ProfilePreviewList.fromProfileList(
    profileList,
    notifier,
    scaffoldKey,
  );
}

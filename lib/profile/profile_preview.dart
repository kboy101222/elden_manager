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
    this.image = "data/images/elden_ring_icon.png",
    this.notifier,
  });

  final String name;
  final String description;
  final String image;
  final Profile profile;
  final ModManagerModel? notifier;

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
          if (widget.notifier != null) {
            widget.notifier?.setCurrentProfile(widget.profile);
            // widget.scaffoldKey?.currentState!.closeDrawer();
            Navigator.pop(context);
          }
        },
        icon: Icon(Icons.play_arrow_outlined),
        tooltip: "Load Profile",
      ),
    );
  }
}

class ProfilePreviewList extends StatefulWidget {
  const ProfilePreviewList({super.key, required this.children, this.notifier});

  final List<ProfilePreview> children;
  final ModManagerModel? notifier;

  static Future<ProfilePreviewList> fromProfileList(
    ProfileList profileList,
    ModManagerModel? notifier,
  ) async {
    List<ProfilePreview> elementList = [];

    for (Profile profile in profileList.profiles) {
      elementList.add(
        ProfilePreview(
          name: profile.name,
          description: profile.description,
          image: profile.image,
          notifier: notifier,
          profile: profile,
        ),
      );
    }

    return ProfilePreviewList(children: elementList);
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
          // child: Text(
          //   "Profiles",
          //   style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
          // ),
          child: Column(
            children: [
              Text(
                "Profiles",
                style: Theme.of(context).textTheme.headlineSmall?.merge(
                  TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                ),
              ),
              Spacer(),
              IconTheme(
                data: IconThemeData(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add),
                      tooltip: "Create New Profile",
                    ),
                    IconButton(
                      onPressed: null,
                      icon: Icon(Icons.file_download_outlined),
                      tooltip: "Import Elden Manager Profile (WIP)",
                    ),
                    IconButton(
                      onPressed: null,
                      icon: Icon(Icons.file_copy_outlined),
                      tooltip: "Import ME3 Profile (WIP)",
                    ),
                  ],
                ),
              ),
            ],
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
) async {
  ProfileList profileList = getProfiles(profilesFolder);
  return await ProfilePreviewList.fromProfileList(profileList, notifier);
}

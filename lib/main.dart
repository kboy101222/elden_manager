import 'package:elden_manager/mod.dart';
import 'package:elden_manager/mod_engine_3.dart';
import 'package:elden_manager/profile/profile.dart';
import 'package:elden_manager/profile/profile_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model_manager.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ModManagerModel(),
      child: EldenModManager(),
    ),
  );
}

class EldenModManager extends StatelessWidget {
  const EldenModManager({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elden Mod Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: ProfilesPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class ProfilesPage extends StatefulWidget {
  const ProfilesPage({super.key, required this.title});

  final String title;

  @override
  State<ProfilesPage> createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<UpdateBar> futureUpdateBar;
  // late Future<ProfilePreviewList> profileList;
  // late Future<ProfileList> profileList;
  late Future<ProfilePreviewList> profilePreviews;

  ModManagerModel notifier = ModManagerModel();
  @override
  void initState() {
    super.initState();
    ModEngine3 modEngine = ModEngine3();
    futureUpdateBar = createUpdateBar(modEngine);
    profilePreviews = createProfilePreviewList("data/profiles", notifier);

    ProfileList profileList = notifier.profileList;
    String defaultProfile = notifier.getSetting("defaultProfile") ?? "";
    if (defaultProfile != "") {
      notifier.setCurrentProfile(profileList[defaultProfile]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text("Elden Manager"),
        actions: [
          IconButton(
            onPressed: null,
            icon: Icon(Icons.file_open_outlined),
            tooltip: "Import Profile",
          ),
          IconButton(
            onPressed: null,
            icon: Icon(Icons.play_arrow),
            tooltip: "Launch Elden Ring",
          ),
        ],
      ),
      drawer: Drawer(
        key: scaffoldKey,
        elevation: 1.0,
        child: FutureBuilder<ProfilePreviewList>(
          future: profilePreviews,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!;
            } else if (snapshot.hasError) {
              return ProfilePreviewList(
                children: [
                  ProfilePreview(
                    name: "ERROR",
                    description: "There was an error retrieving profiles!",
                    profile: Profile(name: "Error", fileName: "Error"),
                  ),
                ],
              );
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                ListenableBuilder(
                  listenable: notifier,
                  builder: (context, Widget? child) {
                    if (notifier.currentProfile != null) {
                      return Text(
                        "Current Profile: ${notifier.currentProfile!.name}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      );
                    } else {
                      return TextButton.icon(
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        label: Text("Click to select a profile"),
                        icon: Icon(Icons.arrow_circle_up),
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSecondary,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

            Row(
              children: [
                Text(
                  "Mods:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ListenableBuilder(
                    listenable: notifier,
                    builder: (context, Widget? child) {
                      if (notifier.currentProfile != null) {
                        if (notifier.currentModList != null) {
                          return ModTileList(
                            modList: notifier.currentModList!,
                            notifier: notifier,
                          );
                        }
                        return Text(
                          "The selected profile doesn't seem to have any mods! Start adding some with the buttons above.",
                        );
                      }
                      return Text("Please select a profile to view mods");
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: FutureBuilder<UpdateBar>(
        future: futureUpdateBar,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!;
          } else if (snapshot.hasError) {
            return UpdateBar(
              children: [
                Text(
                  "There was an error checking for updates: ${snapshot.error.toString()}",
                ),
              ],
            );
          }

          return const LinearProgressIndicator();
        },
      ),
    );
  }
}

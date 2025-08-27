// ignore_for_file: avoid_print

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
    print("Initializing");
    ModEngine3 modEngine = ModEngine3();
    futureUpdateBar = createUpdateBar(modEngine);
    // profileList = getProfiles("config/profiles");
    // profilePreviews = buildFromProfileList("config/profiles", notifier);
    profilePreviews = createProfilePreviewList(
      "config/profiles",
      notifier,
      scaffoldKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text("Elden Manager"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.play_arrow))],
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
                scaffoldKey: scaffoldKey,
                children: [
                  ProfilePreview(
                    name: "ERROR",
                    description: "There was an error retrieving profiles!",
                    profile: Profile(
                      name: "Error",
                      fileName: "Error",
                      modList: [],
                    ),
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
                    return Text(
                      "Current Profile: ${notifier.currentProfile ?? "None"}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    );
                  },
                ),
              ],
            ),

            Row(
              children: [
                Text(
                  "Mods:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                ),
              ],
            ),
            Row(children: [Text("Mod list will go here")]),
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

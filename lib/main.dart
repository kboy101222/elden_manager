// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:elden_manager/launcher.dart';
import 'package:elden_manager/mod_engine_3.dart';
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

// class ModManagerModel extends ChangeNotifier {
//   // bool isME3Installed = false;
//   // String me3Version = "1.0.0";

//   // bool me3HasUpdate = false;
//   // String latestME3Version = "";
//   // Uri updateURL = Uri.parse("");

//   // List<String> profileList = [];
//   // JsonConfig? config;

//   // bool havePerformedUpdateCheck = false;
//   // bool havePerformedInstallCheck = false;

//   // void checkUpdate() {
//   //   if (!havePerformedUpdateCheck) {
//   //     http
//   //         .get(
//   //           Uri.https(
//   //             "api.github.com",
//   //             "repos/garyttierney/me3/releases/latest",
//   //           ),
//   //         )
//   //         .then((response) {
//   //           print("recieved data from server...");
//   //           print("Status code ${response.statusCode}");
//   //           if (response.statusCode == 200) {
//   //             print("data was valid");
//   //             var content = jsonDecode(response.body);
//   //             Version newVersion = Version.parse(
//   //               content["name"].toString().replaceFirst("v", ""),
//   //             );
//   //             Version currentVersion = Version.parse(me3Version);
//   //             // Version currentVersion = Version.parse("0.0.1");

//   //             if (newVersion > currentVersion) {
//   //               print("New Version Available!");
//   //               print("New Version: $newVersion");
//   //               print("Update URL: ${content["html_url"]}");
//   //               me3HasUpdate = true;
//   //               latestME3Version = newVersion.toString();
//   //               updateURL = Uri.parse(content["html_url"]);
//   //               havePerformedUpdateCheck = true;
//   //             } else {
//   //               print("No updates available");
//   //               latestME3Version = newVersion.toString();
//   //               havePerformedUpdateCheck = true;
//   //             }
//   //             notifyListeners();
//   //           } else {
//   //             havePerformedUpdateCheck = true;
//   //             latestME3Version = "Unable to acquire new version";
//   //             print("Invalid response from GitHub: ${response.statusCode}");
//   //             notifyListeners();
//   //           }
//   //         });
//   //   }
//   // }

//   // void getProfileList() {
//   //   List<String> profileList = [];
//   //   Directory("config/profiles").list().listen(
//   //     (FileSystemEntity entity) {
//   //       profileList.add(entity.path);
//   //     },
//   //     onDone: () {
//   //       print("Done parsing profiles");
//   //       notifyListeners();
//   //     },
//   //   );
//   // }

//   // void readConfig() {
//     File("config/user_settings.json").readAsString().then((String contents) {
//       final configData = JsonConfig.fromJson(contents);
//       if (configData.isDebugMode) print(configData.debugString);
//       config = configData;
//       notifyListeners();
//     });
//   }
// }

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
  late Future<UpdateBar> futureUpdateBar;
  @override
  void initState() {
    super.initState();
    print("Initializing");
    ModEngine3 modEngine = ModEngine3();
    futureUpdateBar = createUpdateBar(modEngine);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle mediumWhiteText = TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
      fontSize: 15,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text("Elden Manager"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.play_arrow))],
      ),
      drawer: Drawer(
        child: Consumer<ModManagerModel>(
          builder: (context, data, child) {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Text(
                    "Profiles",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
                ProfilePreview(
                  name: "Test",
                  description: "This is here as a test of the system!",
                ),
              ],
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Mods:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomAppBar(
      //   elevation: 1.0,
      //   color: Theme.of(context).colorScheme.primary,
      //   child: IconTheme(
      //     data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      //     child: Consumer<ModManagerModel>(
      //       builder: (context, data, child) {
      //         return Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //           children: <Widget>[
      //             if (!data.me3Installed)
      //               Launcher(
      //                 url: Uri.parse(
      //                   "https://github.com/garyttierney/me3/releases/latest",
      //                 ),
      //                 label:
      //                     "Click here to download ME3. Click refresh after install.",
      //               ),
      //             if (!data.me3Installed)
      //               IconButton(
      //                 onPressed: data.modEngineInfo.checkIfInstalled,
      //                 icon: Icon(Icons.refresh),
      //               ),
      //             if (data.me3Installed)
      //               Text(
      //                 "Mod Engine 3 Version: ${data.modEngineInfo.version}",
      //                 style: mediumWhiteText,
      //               ),
      //             if (data.me3Installed)
      //               Text(
      //                 "Latest Version: ${data.latestME3Version}",
      //                 style: mediumWhiteText,
      //               ),
      //             if (data.me3HasUpdate)
      //               Launcher(
      //                 url: Uri.parse(
      //                   "https://github.com/garyttierney/me3/releases/latest",
      //                 ),
      //                 label:
      //                     "ME3 Update Available (${data.currentME3Version} > ${data.latestME3Version}). Click to update.",
      //               ),
      //           ],
      //         );
      //       },
      //     ),
      //   ),
      // ),
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

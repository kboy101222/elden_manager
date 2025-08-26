// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:elden_manager/launcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:version/version.dart';

import 'json_config.dart';

void main() {
  runApp(const EldenModManager());
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
  bool isME3Installed = false;
  String me3Version = "";

  bool havePerformedUpdateCheck = false;
  bool me3HasUpdate = false;
  String newME3Version = "";
  Uri updateURL = Uri.parse("");

  @override
  void initState() {
    super.initState();
    print("Initializing");
    getModEngine3Install();
    setState(() {
      isME3Installed = false;
    });

    http
        .get(
          Uri.https("api.github.com", "repos/garyttierney/me3/releases/latest"),
        )
        .then((response) {
          print("recieved data from server...");
          print("Status code ${response.statusCode}");
          if (response.statusCode == 200) {
            print("data was valid");
            var content = jsonDecode(response.body);
            Version newVersion = Version.parse(
              content["name"].toString().replaceFirst("v", ""),
            );
            Version currentVersion = Version.parse(me3Version);
            // Version currentVersion = Version.parse("0.0.1");

            if (newVersion > currentVersion) {
              print("New Version Available!");
              print("New Version: $newVersion");
              print("Update URL: ${content["html_url"]}");
              setState(() {
                me3HasUpdate = true;
                newME3Version = newVersion.toString();
                updateURL = Uri.parse(content["html_url"]);
                havePerformedUpdateCheck = true;
              });
            } else {
              print("No updates available");
              newME3Version = newVersion.toString();
            }
          } else {
            setState(() {
              havePerformedUpdateCheck = true;
              newME3Version = "Unable to acquire new version";
            });
            print("Invalid response from GitHub: ${response.statusCode}");
          }
        });
  }

  void getModEngine3Install() {
    print("Checking if ME3 is installed");
    Process.run('me3', ['-V']).then((value) {
      if (value.stdout.toString().contains("me3")) {
        print("ME3 is installed!");
        List<String> output = value.stdout.toString().split(" ");

        setState(() {
          isME3Installed = true;
          me3Version = output.last.trim();
        });
      } else {
        print("ME3 is not installed!");
        setState(() {
          isME3Installed = false;
          me3Version = "";
        });
      }
    });
  }

  void readConfig() async {
    File("config/user_settings.json").readAsString().then((String contents) {
      final configData = JsonConfig.fromJson(contents);
      if (configData.isDebugMode) print(configData.debugString);
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle mediumWhiteText = TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
      fontSize: 15,
    );

    readConfig();
    // getModEngine3Install();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text("Elden Manager"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.play_arrow))],
      ),
      drawer: Drawer(
        child: ListView(
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
          ],
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
      bottomNavigationBar: BottomAppBar(
        elevation: 1.0,
        color: Theme.of(context).colorScheme.primary,
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              if (!isME3Installed)
                Launcher(
                  url: Uri.parse(
                    "https://github.com/garyttierney/me3/releases/latest",
                  ),
                  label:
                      "Click here to download ME3. Click refresh after install.",
                ),
              if (!isME3Installed)
                IconButton(
                  onPressed: getModEngine3Install,
                  icon: Icon(Icons.refresh),
                ),
              if (isME3Installed)
                Text(
                  "Mod Engine 3 Version $me3Version",
                  style: mediumWhiteText,
                ),
              if (isME3Installed)
                Text("Latest Version: $newME3Version", style: mediumWhiteText),
              if (me3HasUpdate)
                Launcher(
                  url: updateURL,
                  label:
                      "ME3 Update Available ($me3Version > $newME3Version). Click to update.",
                ),
            ],
          ),
        ),
      ),
    );
  }
}

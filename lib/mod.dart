import 'package:elden_manager/model_manager.dart';
import 'package:flutter/material.dart';

class Mod {
  Mod({
    required this.name,
    String? displayName,
    this.description = "",
    this.author = "",
    this.iconImage = "",
    this.image = "",
    this.isEnabled = true,
  }) : displayName = displayName ?? name;

  String name;
  String displayName;
  String description;
  String author;
  String image;
  String iconImage;
  bool isEnabled;

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "displayName": displayName,
      "description": description,
      "author": author,
      "iconImage": iconImage,
      "image": image,
      "isEnabled": isEnabled,
    };
  }

  @override
  String toString() {
    return "$name (by ${author != "" ? author : "unknown"}) - ${description != "" ? description : "No description provided"}";
  }

  @override
  bool operator ==(Object other) {
    if (other is Mod && hashCode == other.hashCode) {
      return true;
    }
    return false;
  }

  @override
  int get hashCode =>
      Object.hash(name, description, author, iconImage, displayName, image);
}

class ModList {
  ModList({List<Mod>? mods}) : mods = mods ?? [];

  List<Mod> mods;

  void add(Mod mod) {
    mods.add(mod);
  }

  bool remove(Mod mod) {
    return mods.remove(mod);
  }

  List<Map> toJson() {
    List<Map> modList = [];
    for (Mod mod in mods) {
      modList.add(mod.toJson());
    }
    return modList;
  }

  void toggleMod(Mod mod) {
    if (mods.contains(mod)) {
      mods[mods.indexOf(mod)].isEnabled = !mods[mods.indexOf(mod)].isEnabled;
    }
  }

  operator [](Object other) {
    if (other is Mod) {
      for (Mod mod in mods) {
        if (other == mod) return mod;
      }
      return null;
    }
  }

  @override
  String toString() {
    String returnString = "[ ";
    for (var mod in mods) {
      returnString += "$mod, ";
    }
    return returnString;
  }
}

class ModTile extends StatelessWidget {
  const ModTile({super.key, required this.mod, required this.notifier});

  final Mod mod;
  final ModManagerModel notifier;

  @override
  Widget build(BuildContext context) {
    Text subtitle;

    if (mod.description != "") {
      subtitle = Text(
        mod.description,
        style: Theme.of(context).listTileTheme.subtitleTextStyle,
      );
    } else {
      subtitle = Text(
        "No Description",
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    }

    return ListTile(
      title: Text(
        mod.displayName,
        style: Theme.of(context).listTileTheme.titleTextStyle,
      ),
      subtitle: Row(children: [subtitle, Spacer(), Text(mod.author)]),
      trailing: Checkbox(
        value: notifier.currentModList![mod].isEnabled,
        onChanged: (onChanged) {
          notifier.toggleMod(mod);
        },
      ),
    );
  }
}

List<ModTile> buildModListTiles(ModList modList, ModManagerModel notifier) {
  List<ModTile> modTileList = [];

  for (Mod mod in modList.mods) {
    modTileList.add(ModTile(mod: mod, notifier: notifier));
  }

  return modTileList;
}

class ModTileList extends StatelessWidget {
  const ModTileList({super.key, required this.modList, required this.notifier});

  final ModList modList;
  final ModManagerModel notifier;

  @override
  Widget build(BuildContext context) {
    List<ModTile> modTileList = [];

    for (Mod mod in modList.mods) {
      modTileList.add(ModTile(mod: mod, notifier: notifier));
    }

    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      children: modTileList,
    );
  }
}

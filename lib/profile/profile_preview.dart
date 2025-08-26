import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class ProfilePreview extends StatelessWidget {
  const ProfilePreview({
    super.key,
    required this.name,
    required this.description,
    this.image = "config/images/elden_ring_icon.png",
  });

  final String name;
  final String description;
  final String image;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Image.file(File(image), fit: BoxFit.contain),
      ),
      title: Text(name),
      subtitle: Text(description),
      trailing: IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
    );
  }

  factory ProfilePreview.fromJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return ProfilePreview(name: data["name"], description: data["description"]);
  }
}

class ProfilePreviewList {
  const ProfilePreviewList({required this.children});

  final List<ProfilePreview> children;

  // static Future<ProfilePreviewList> fromFileList(List<String> fileList) async {
  //   List<ProfilePreview> elementList = [];

  //   for (String file in fileList) {

  //   }
  // }
}

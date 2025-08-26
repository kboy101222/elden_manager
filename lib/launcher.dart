import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Launcher extends StatelessWidget {
  const Launcher({
    super.key,
    required this.url,
    required this.label,
    this.icon,
  });

  final Uri url;
  final String label;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return ElevatedButton(
        onPressed: () {
          _launchUrl();
        },
        child: Text(label),
      );
    } else {
      return IconButton(onPressed: _launchUrl, icon: icon!);
    }
  }

  Future<void> _launchUrl() async {
    print("launching URL $url");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  }
}

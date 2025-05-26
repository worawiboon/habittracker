import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habittracker/controllers/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the ThemeController instance
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Obx(() => SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Enable or disable dark theme'),
                  value: themeController.isDarkMode,
                  onChanged: (bool value) {
                    themeController.toggleTheme(value);
                  },
                  secondary: Icon(
                    themeController.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                )),
            // Add other settings here in the future
          ],
        ),
      ),
    );
  }
}

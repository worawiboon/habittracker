import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();
  final _themeKey = 'isDarkMode'; // Key for storing theme preference

  // .obs ทำให้ GetX รู้ว่าเมื่อค่านี้เปลี่ยน UI ที่เกี่ยวข้องต้อง update
  final RxBool _isDarkMode = false.obs;

  // Getter to access the current theme mode
  ThemeMode get themeMode =>
      _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
  // Getter to allow widgets to listen to isDarkMode changes
  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }

  void _loadThemeFromStorage() {
    _isDarkMode.value = _storage.read<bool>(_themeKey) ??
        false; // Default to light mode if not found
    Get.changeThemeMode(themeMode);
    update(); // Ensure UI updates with loaded theme
  }

  void toggleTheme(bool darkModeEnabled) {
    _isDarkMode.value = darkModeEnabled;
    _storage.write(_themeKey, _isDarkMode.value);
    Get.changeThemeMode(themeMode);
    update(); // Notify listeners to rebuild
  }

  // Define your light theme data
  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal, brightness: Brightness.light),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          elevation: 4.0,
          titleTextStyle: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors
                .white, // Ensure title text color is white for light theme appbar
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.teal.shade600,
          foregroundColor: Colors.white,
        ),
        // Add other specific light theme properties here
      );

  // Define your dark theme data
  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal, brightness: Brightness.dark),
        useMaterial3: true,
        // AppBar theme for dark mode can be customized if needed, or it will adapt
        // For example, if you want a different AppBar color in dark mode:
        // appBarTheme: AppBarTheme(
        //   backgroundColor: Colors.grey.shade900,
        //   foregroundColor: Colors.white,
        // ),
        // Add other specific dark theme properties here
      );
}

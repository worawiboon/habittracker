import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:get_storage/get_storage.dart'; // Import GetStorage
import 'package:habittracker/controllers/habit_controller.dart'; // จะสร้างไฟล์นี้ในขั้นตอนต่อไป
import 'package:habittracker/controllers/theme_controller.dart'; // Import ThemeController
import 'package:habittracker/habit.dart'; // แก้ไข path ที่นี่
import 'package:flutter_slidable/flutter_slidable.dart'; // Import flutter_slidable
import 'package:habittracker/pages/settings_page.dart'; // Import SettingsPage
import 'package:habittracker/pages/habit_detail_page.dart'; // Import HabitDetailPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // Initialize GetStorage
  Get.put(HabitController());
  Get.put(ThemeController()); // Initialize ThemeController
  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController =
        Get.find(); // Get ThemeController instance

    // Wrap with Obx to listen to theme changes
    return Obx(() => GetMaterialApp(
          title: 'Habit Tracker',
          theme: themeController.lightTheme, // Use lightTheme from controller
          darkTheme: themeController.darkTheme, // Use darkTheme from controller
          themeMode: themeController.themeMode, // Use themeMode from controller
          // ThemeData properties (useMaterial3, appBarTheme, etc.)
          // are now defined within lightTheme and darkTheme in ThemeController.
          // They should not be duplicated here.
          home: HabitListPage(),
        ));
  }
}

class HabitListPage extends GetView<HabitController> {
  // เปลี่ยนเป็น GetView<HabitController>
  // const HabitListPage({super.key, required this.title}); // ลบ constructor เดิม
  // final String title; // ลบ title

  HabitListPage({super.key}); // Constructor ใหม่

  final TextEditingController _textFieldController = TextEditingController();

  void _displayAddHabitDialog(BuildContext context) async {
    _textFieldController.clear();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Habit'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Enter habit name"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('ADD'),
              onPressed: () {
                if (_textFieldController.text.isNotEmpty) {
                  controller.addHabit(_textFieldController.text);
                  _textFieldController.clear();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog สำหรับแก้ไข Habit
  void _displayEditHabitDialog(
      BuildContext context, int index, String currentName) async {
    _textFieldController.text = currentName; // ใส่ชื่อปัจจุบันใน TextField
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Habit'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Enter new habit name"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                _textFieldController.clear();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('SAVE'),
              onPressed: () {
                if (_textFieldController.text.isNotEmpty) {
                  controller.editHabit(index, _textFieldController.text);
                  _textFieldController.clear();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Habit Tracker'), // ใส่ Title ตรงนี้เลย
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Get.to(() => const SettingsPage()); // Navigate to SettingsPage
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.habits.isEmpty) {
          return const Center(
            child: Column(
              // ปรับปรุง Empty State
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rule_folder, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No Habits Yet",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  "Tap the '+' button to add your first habit!",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8.0), // เพิ่ม padding รอบ ListView
          itemCount: controller.habits.length,
          itemBuilder: (context, index) {
            final habit = controller.habits[index];
            return Slidable(
              key: Key(habit.name + index.toString()), // Key สำหรับ Slidable
              endActionPane: ActionPane(
                // Action pane ที่จะปรากฏเมื่อ swipe จากขวาไปซ้าย
                motion: const StretchMotion(), // Animation style
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      // Action สำหรับ Delete
                      controller.deleteHabit(index);
                      Get.snackbar(
                        "Habit Deleted",
                        "'${habit.name}' was removed.",
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                    },
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    icon: Icons.delete_sweep,
                    label: 'Delete',
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  SlidableAction(
                    onPressed: (context) {
                      // Action สำหรับ Edit
                      _displayEditHabitDialog(context, index, habit.name);
                    },
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ],
              ),
              child: Card(
                // ใช้ Card widget
                elevation: 3.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: ListTile(
                  onTap: () {
                    // Add onTap for navigation
                    Get.to(() => HabitDetailPage(habit: habit));
                  },
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  title: Text(
                    habit.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 18.0),
                  ),
                  leading: Checkbox(
                    value: habit.isCompletedToday,
                    onChanged: (bool? value) {
                      controller.toggleHabitCompleted(index);
                    },
                    activeColor: Colors.teal, // สี Checkbox เมื่อถูกเลือก
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayAddHabitDialog(context),
        tooltip: 'Add Habit',
        child: const Icon(Icons.playlist_add),
      ),
    );
  }
}

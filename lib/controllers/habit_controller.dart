import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:habittracker/habit.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class HabitController extends GetxController {
  // ใช้ .obs เพื่อทำให้ list นี้ reactive
  var habits = <Habit>[].obs;
  final _storage = GetStorage();
  final _habitStorageKey = 'habits';

  @override
  void onInit() {
    super.onInit();
    debugPrint("[HabitController] onInit called");
    _loadHabitsFromStorage();
  }

  void _loadHabitsFromStorage() {
    debugPrint("[HabitController] Attempting to load habits from storage...");
    try {
      final storedHabitsRaw = _storage.read<List>(_habitStorageKey);
      debugPrint("[HabitController] Raw data from storage: $storedHabitsRaw");

      if (storedHabitsRaw != null) {
        final loadedHabits = storedHabitsRaw
            .map((item) {
              try {
                // Ensure item is a Map before attempting to convert
                if (item is Map) {
                  return Habit.fromJson(Map<String, dynamic>.from(item));
                } else {
                  debugPrint(
                      "[HabitController] Invalid item type in stored data: $item");
                  return null; // Skip invalid item
                }
              } catch (e) {
                debugPrint(
                    "[HabitController] Error parsing individual habit: $item, Error: $e");
                return null; // Skip item if parsing fails
              }
            })
            .where((habit) =>
                habit != null) // Filter out any nulls that resulted from errors
            .cast<Habit>()
            .toList();

        habits.assignAll(loadedHabits); // Use assignAll to update RxList
        debugPrint(
            "[HabitController] Loaded ${habits.length} habits successfully.");
      } else {
        debugPrint(
            "[HabitController] No habits found in storage. Initializing with empty list.");
        habits.assignAll([]); // Ensure list is empty if nothing stored
      }
    } catch (e) {
      debugPrint(
          "[HabitController] CRITICAL: Failed to load habits from storage: $e");
      habits.assignAll([]); // Default to empty list on critical failure
    }
    // Make sure UI updates even if list was already empty or remains empty
    habits.refresh();
  }

  void _saveHabitsToStorage() {
    try {
      _storage.write(_habitStorageKey, habits.map((e) => e.toJson()).toList());
      debugPrint("[HabitController] Saved ${habits.length} habits to storage.");
    } catch (e) {
      debugPrint("[HabitController] Failed to save habits: $e");
    }
  }

  // Method สำหรับเพิ่ม habit ใหม่
  void addHabit(String name) {
    if (name.isNotEmpty) {
      habits.add(Habit(name: name));
      _saveHabitsToStorage();
    }
  }

  // Method สำหรับสลับสถานะ isCompletedToday ของ habit
  void toggleHabitCompleted(int index) {
    if (index >= 0 && index < habits.length) {
      // Determine the new completion status before calling updateCompletionStatus
      bool newCompletionStatus = !habits[index].isCompletedToday;

      habits[index].updateCompletionStatus(newCompletionStatus);
      // isCompletedToday is now updated by updateCompletionStatus method in Habit model

      habits.refresh(); // Refresh the list to update UI
      _saveHabitsToStorage(); // Save changes
    }
  }

  // Method สำหรับลบ habit
  void deleteHabit(int index) {
    if (index >= 0 && index < habits.length) {
      habits.removeAt(index);
      _saveHabitsToStorage();
    }
  }

  // Method สำหรับแก้ไขชื่อ habit
  void editHabit(int index, String newName) {
    if (index >= 0 && index < habits.length && newName.isNotEmpty) {
      habits[index].name = newName;
      habits.refresh();
      _saveHabitsToStorage();
    }
  }

  // Method to update notes for a specific habit
  void updateHabitNotes(int habitGlobalIndex, String newNotes) {
    // We need to find the habit in the main list by some unique identifier
    // or pass its direct index if HabitDetailPage knows it.
    // Assuming HabitDetailPage will provide the correct index from the main habits list.
    if (habitGlobalIndex >= 0 && habitGlobalIndex < habits.length) {
      habits[habitGlobalIndex].notes = newNotes;
      habits
          .refresh(); // Update the UI if notes are displayed on the main list (not in this case yet)
      _saveHabitsToStorage(); // Save changes to storage
      // Potentially update a specific habit instance if GetX is managing individual habit states for detail pages
      // For now, this direct update and save should be fine if detail page re-reads or is rebuilt.
      Get.snackbar("Notes Saved",
          "Notes for '${habits[habitGlobalIndex].name}' updated.",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      debugPrint(
          "[HabitController] Error: Tried to update notes for invalid index $habitGlobalIndex");
    }
  }

  // TODO: พิจารณาการ persist ข้อมูล (เช่น ใช้ GetStorage หรือฐานข้อมูลอื่นๆ)
}

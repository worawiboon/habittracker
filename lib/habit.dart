class Habit {
  String name;
  bool isCompletedToday;
  int streakCount;
  DateTime? lastCompletedDate;
  List<DateTime> completionDates;

  Habit({
    required this.name,
    this.isCompletedToday = false,
    this.streakCount = 0,
    this.lastCompletedDate,
    List<DateTime>? completionDates,
  }) : completionDates = completionDates ?? [];

  // Method to convert a Habit object to a Map
  Map<String, dynamic> toJson() => {
        'name': name,
        'isCompletedToday': isCompletedToday,
        'streakCount': streakCount,
        'lastCompletedDate':
            lastCompletedDate?.toIso8601String(), // Store as ISO 8601 string
        'completionDates':
            completionDates.map((date) => date.toIso8601String()).toList(),
      };

  // Factory constructor to create a Habit object from a Map
  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        name: json['name'] as String,
        isCompletedToday: json['isCompletedToday'] as bool? ?? false,
        streakCount: json['streakCount'] as int? ?? 0,
        lastCompletedDate: json['lastCompletedDate'] != null
            ? DateTime.tryParse(json['lastCompletedDate'] as String)
            : null,
        completionDates: (json['completionDates'] as List<dynamic>? ?? [])
            .map((dateString) => DateTime.tryParse(dateString as String))
            .where((date) => date != null)
            .cast<DateTime>()
            .toList(),
      );

  // Helper to check if a date is today
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Call this method when a habit is marked as completed or not
  void updateCompletionStatus(bool completed) {
    DateTime now = DateTime.now();
    DateTime today =
        DateTime(now.year, now.month, now.day); // Normalize to midnight

    if (completed) {
      // Add to completionDates if not already there for today
      if (!completionDates.any((date) => _isSameDate(date, today))) {
        completionDates.add(today);
        completionDates.sort(); // Keep dates sorted, optional but can be useful
      }

      if (isCompletedToday &&
          _isSameDate(lastCompletedDate ?? DateTime(0), today)) {
        // Already completed today and marked again, no change to streak or date
        return;
      }

      isCompletedToday = true;

      if (lastCompletedDate != null) {
        DateTime yesterday = today.subtract(const Duration(days: 1));
        if (_isSameDate(lastCompletedDate!, today)) {
          // Marked completed again on the same day (e.g., uncheck then check)
          // Streak already counted, no change needed unless it was reset by unchecking.
          // This case might need more logic if unchecking resets streak immediately.
          // For now, assume if it's marked completed today, it's part of today's streak.
        } else if (_isSameDate(lastCompletedDate!, yesterday)) {
          streakCount++;
        } else {
          // Last completion was not today or yesterday, so reset streak
          streakCount = 1;
        }
      } else {
        // First time completing this habit or streak was broken
        streakCount = 1;
      }
      lastCompletedDate = today;
    } else {
      // Remove from completionDates if it was there for today
      completionDates.removeWhere((date) => _isSameDate(date, today));

      // Marked as not completed
      isCompletedToday = false;
      // If it was completed today, and now it's not, the streak for *today* is broken.
      // The previous streak before today should remain if lastCompletedDate was yesterday.
      if (lastCompletedDate != null && _isSameDate(lastCompletedDate!, today)) {
        // If it was marked complete today, and now it's not, reduce streak
        // and effectively revert lastCompletedDate as if today's completion didn't happen for streak purposes.
        streakCount = (streakCount - 1)
            .clamp(0, 10000); // Ensure streak doesn't go below 0
        // What should lastCompletedDate be? If streak is > 0, it should be yesterday.
        // If streak becomes 0, it means no prior consecutive days.
        if (streakCount > 0) {
          // Check if there was a completion yesterday in completionDates to maintain streak
          DateTime yesterday = today.subtract(const Duration(days: 1));
          if (completionDates.any((date) => _isSameDate(date, yesterday))) {
            lastCompletedDate = yesterday;
          } else {
            // No completion yesterday, so streak effectively ended before today
            // This might mean streakCount should be re-evaluated based on completionDates
            // For simplicity now, we just set lastCompletedDate to null if streak became 0 this way
            lastCompletedDate = null;
          }
        } else {
          lastCompletedDate = null;
        }
      }
      // If lastCompletedDate was not today, unchecking doesn't affect past streak.
    }
  }
}

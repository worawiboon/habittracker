import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habittracker/habit.dart';
// import 'package:habittracker/controllers/habit_controller.dart'; // Commented out if not directly used
import 'package:table_calendar/table_calendar.dart'; // Import TableCalendar

class HabitDetailPage extends StatefulWidget {
  // Changed to StatefulWidget for calendar state
  final Habit habit;
  const HabitDetailPage({super.key, required this.habit});

  @override
  State<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends State<HabitDetailPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Event loader function for TableCalendar
  List<DateTime> _getEventsForDay(DateTime day) {
    // Return a list of events (completion dates) for the given day
    // This is a simple way if you only mark the day.
    // If you have multiple events per day, you'd return a list of your event objects.
    return widget.habit.completionDates
        .where((date) => isSameDay(date, day))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
      ),
      body: SingleChildScrollView(
        // Added SingleChildScrollView for potentially long content
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habit: ${widget.habit.name}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Completed Today: ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Icon(
                  widget.habit.isCompletedToday
                      ? Icons.check_circle
                      : Icons.cancel_outlined,
                  color:
                      widget.habit.isCompletedToday ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Current Streak: ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${widget.habit.streakCount} day(s)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.habit.streakCount > 0
                            ? Colors.orange.shade700
                            : Colors.grey,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Completion Calendar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TableCalendar<DateTime>(
              // Added TableCalendar
              firstDay:
                  DateTime.utc(2020, 1, 1), // Example: Allow dates from 2020
              lastDay: DateTime.utc(DateTime.now().year + 5, 12,
                  31), // Example: Allow dates up to 5 years from now
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              selectedDayPredicate: (day) {
                // Use `selectedDayPredicate` to determine which day is currently selected.
                // If this returns true, then `day` will be marked as selected.
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  // Call `setState()` when updating the selected day
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay =
                        focusedDay; // update `_focusedDay` here as well
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                // No need to call `setState()` here
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                // Customize markers
                markerDecoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary, // Use primary color from theme
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible:
                    true, // Show/hide format button (month, 2 weeks, week)
                titleCentered: true,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Future Enhancements:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            // const Text('- Streak count'), // Already implemented
            // const Text('- Calendar view of completions'), // Implemented
            const Text('- Notes for this habit'),
            const Text('- Charts/Progress visualization'),
          ],
        ),
      ),
    );
  }
}

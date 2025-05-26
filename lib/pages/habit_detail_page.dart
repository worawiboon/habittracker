import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habittracker/habit.dart';
import 'package:habittracker/controllers/habit_controller.dart'; // Now we need this
import 'package:table_calendar/table_calendar.dart'; // Import TableCalendar
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
import 'package:intl/intl.dart'; // For date formatting if needed later

class HabitDetailPage extends StatefulWidget {
  // Changed to StatefulWidget for calendar state
  final Habit habit;
  final int habitIndex; // Add habitIndex

  const HabitDetailPage(
      {super.key,
      required this.habit,
      required this.habitIndex}); // Modify constructor

  @override
  State<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends State<HabitDetailPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late TextEditingController _notesController; // For notes TextField
  final HabitController _habitController =
      Get.find(); // Get HabitController instance

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.habit.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Event loader function for TableCalendar
  List<DateTime> _getEventsForDay(DateTime day) {
    // Return a list of events (completion dates) for the given day
    // This is a simple way if you only mark the day.
    // If you have multiple events per day, you'd return a list of your event objects.
    return widget.habit.completionDates
        .where((date) => isSameDay(date, day))
        .toList();
  }

  // Helper method to get week number for a date (simple version)
  int _getWeekOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final firstMonday = startOfYear.weekday == DateTime.monday
        ? startOfYear
        : startOfYear.add(
            Duration(days: (DateTime.monday - startOfYear.weekday + 7) % 7));
    if (date.isBefore(firstMonday) && date.year == startOfYear.year)
      return 52; // or 53 for previous year, simplifying here
    return ((date.difference(firstMonday).inDays) / 7).floor() + 1;
  }

  // Prepare data for the LineChart: completions per week for the last 6 weeks
  List<FlSpot> _getWeeklyCompletionSpots() {
    List<FlSpot> spots = [];
    if (widget.habit.completionDates.isEmpty) return spots;

    DateTime today = DateTime.now();
    // Normalize today to the beginning of its week (e.g., Monday)
    DateTime startOfThisWeek =
        today.subtract(Duration(days: today.weekday - DateTime.monday));
    if (today.weekday < DateTime.monday) {
      // if today is Sunday, go back further
      startOfThisWeek = startOfThisWeek.subtract(const Duration(days: 7));
    }

    for (int i = 5; i >= 0; i--) {
      // Last 6 weeks, 0 is current week, 5 is 5 weeks ago
      DateTime weekStartDate = startOfThisWeek.subtract(Duration(days: i * 7));
      DateTime weekEndDate = weekStartDate.add(const Duration(days: 6));

      int completionsInWeek = widget.habit.completionDates.where((date) {
        // Normalize date to avoid time-of-day issues
        DateTime completionDay = DateTime(date.year, date.month, date.day);
        return !completionDay.isBefore(DateTime(
                weekStartDate.year, weekStartDate.month, weekStartDate.day)) &&
            !completionDay.isAfter(
                DateTime(weekEndDate.year, weekEndDate.month, weekEndDate.day));
      }).length;

      // X-axis: week number (0 for 5 weeks ago, ..., 5 for current week)
      // Y-axis: number of completions
      spots.add(FlSpot((5 - i).toDouble(), completionsInWeek.toDouble()));
    }
    return spots;
  }

  void _saveNotes() {
    _habitController.updateHabitNotes(widget.habitIndex, _notesController.text);
    // Optionally, update the local widget.habit.notes if you don't rely on GetX to rebuild the whole page
    // setState(() {
    //   widget.habit.notes = _notesController.text;
    // });
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
              'Notes', // Section title for Notes
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add notes for this habit...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest, // Adapts to theme
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                  onPressed: _saveNotes,
                  icon: const Icon(Icons.save_alt_outlined),
                  label: const Text('Save Notes'),
                  style: ElevatedButton.styleFrom(
                      // backgroundColor: Theme.of(context).colorScheme.primary,
                      // foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      )),
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
              'Weekly Progress (Last 6 Weeks)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildWeeklyProgressChart(), // Call method to build the chart
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'More Features Coming Soon!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressChart() {
    final List<FlSpot> spots = _getWeeklyCompletionSpots();
    final lineTouchData = LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
          // You can customize tooltip items further here if needed via getTooltipItems
          ),
    );

    if (spots.isEmpty) {
      return const Center(
        child: Text("Not enough data to display chart yet."),
      );
    }

    return AspectRatio(
      aspectRatio: 1.7, // Adjust aspect ratio as needed
      child: Padding(
        padding:
            const EdgeInsets.only(right: 16.0, left: 6.0, top: 10, bottom: 10),
        child: LineChart(
          LineChartData(
            lineTouchData: lineTouchData,
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    // X-axis: 0=5w ago, 1=4w ago, ..., 5=This Week
                    String text;
                    switch (value.toInt()) {
                      case 0:
                        text = '5W A';
                        break;
                      case 1:
                        text = '4W A';
                        break;
                      case 2:
                        text = '3W A';
                        break;
                      case 3:
                        text = '2W A';
                        break;
                      case 4:
                        text = 'LW';
                        break; // Last Week
                      case 5:
                        text = 'TW';
                        break; // This Week
                      default:
                        return Container();
                    }
                    return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 4,
                        child:
                            Text(text, style: const TextStyle(fontSize: 10)));
                  },
                ),
              ),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval:
                      1, // Adjust based on max completions (e.g., 1, 2, or auto)
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value == 0 || value == 7 || value > 7)
                      return Container(); // Max 7 completions a week
                    return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 4,
                        child: Text(value.toInt().toString(),
                            style: const TextStyle(fontSize: 10)));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
                show: true, border: Border.all(color: Colors.grey.shade300)),
            minX: 0,
            maxX: 5, // 6 weeks (0 to 5)
            minY: 0,
            maxY: 7, // Max 7 completions per week
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary
                  ],
                ),
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

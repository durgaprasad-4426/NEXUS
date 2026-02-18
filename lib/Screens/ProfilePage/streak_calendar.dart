import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StreakCalendar extends StatefulWidget {
  final String userId; // Firestore user document ID
  const StreakCalendar({super.key, required this.userId});

  @override
  State<StreakCalendar> createState() => _StreakCalendarState();
}

class _StreakCalendarState extends State<StreakCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  /// Checks if a given day exists in the active streak set
  bool _isActiveDay(DateTime day, Set<DateTime> activeDays) {
    return activeDays.any((d) =>
        d.year == day.year && d.month == day.month && d.day == day.day);
  }

  /// Converts the Firestore streakMap (Map<String, bool>) into a set of DateTimes
  Set<DateTime> _parseActiveDays(Map<String, dynamic>? streakMap) {
    if (streakMap == null) return {};
    final Set<DateTime> days = {};
    streakMap.forEach((key, value) {
      if (value == true) {
        try {
          days.add(DateTime.parse(key));
        } catch (_) {}
      }
    });
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users") // ✅ your correct collection name
          .doc(widget.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final streakMap = userData['streakMap'] as Map<String, dynamic>? ?? {};

        // Convert streakMap to DateTime Set
        final activeDays = _parseActiveDays(streakMap);

        // ✅ Always include today for UI highlight (visual feedback)
        final today = DateTime.now();
        activeDays.add(DateTime(today.year, today.month, today.day));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Streak Calendar",
              style: TextStyle(
                color: Colors.amber,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.now(),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  if (mounted) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    bool active = _isActiveDay(day, activeDays);
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: active ? Colors.amber : Colors.transparent,
                        shape: BoxShape.circle,
                        border: active
                            ? null
                            : Border.all(color: Colors.white24, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: active ? Colors.black : Colors.white,
                          fontWeight:
                              active ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) => Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  selectedBuilder: (context, day, focusedDay) => Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.amber.withOpacity(0.5), blurRadius: 6)
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: Colors.redAccent),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: Colors.white, size: 28),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

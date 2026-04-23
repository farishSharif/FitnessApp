import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<WorkoutProvider>(
          builder: (context, provider, _) {
            final calendar = provider.userStats?.workoutCalendar ?? {};
            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Calendar',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${provider.currentStreak} day streak',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Month navigation
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => setState(() {
                            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                          }),
                          icon: const Icon(Icons.chevron_left, color: Colors.white),
                        ),
                        Text(
                          _monthName(_focusedMonth),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                          }),
                          icon: const Icon(Icons.chevron_right, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                // Weekday labels
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                          .map((d) => SizedBox(
                                width: 36,
                                child: Text(
                                  d,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Color(0xFF808080), fontSize: 12),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // Calendar grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildCalendarGrid(calendar),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Stats summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(child: _buildSummaryCard('This Month', '${_workoutsThisMonth(calendar)}', 'workouts', Icons.calendar_month)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSummaryCard('Best Streak', '${provider.currentStreak}', 'days', Icons.local_fire_department)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSummaryCard('Total', '${calendar.values.where((v) => v).length}', 'sessions', Icons.fitness_center)),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Recent history header
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Recent Workouts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Completed workouts list
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cw = provider.completedWorkouts[index];
                        return _buildHistoryCard(cw);
                      },
                      childCount: provider.completedWorkouts.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(Map<DateTime, bool> calendar) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    // Monday = 1, so offset = weekday - 1
    final startOffset = (firstDay.weekday - 1) % 7;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNumber = cellIndex - startOffset + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox(width: 36, height: 36);
              }

              final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
              final now = DateTime.now();
              final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
              final isSelected = _selectedDay != null &&
                  date.year == _selectedDay!.year &&
                  date.month == _selectedDay!.month &&
                  date.day == _selectedDay!.day;

              final hasWorkout = calendar.entries
                  .where((e) =>
                      e.key.year == date.year &&
                      e.key.month == date.month &&
                      e.key.day == date.day)
                  .any((e) => e.value);

              return GestureDetector(
                onTap: () => setState(() => _selectedDay = date),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? const Color(0xFF2A2A2A)
                            : hasWorkout
                                ? const Color(0xFF1A3A2A)
                                : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday
                        ? Border.all(color: Colors.white, width: 1.5)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : date.isAfter(now)
                                  ? const Color(0xFF404040)
                                  : Colors.white,
                          fontSize: 14,
                          fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (hasWorkout && !isSelected)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(String label, String value, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4ADE80), size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(color: Color(0xFF808080), fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(CompletedWorkout cw) {
    final mins = cw.duration.inMinutes;
    final dateStr = _formatDate(cw.completedAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fitness_center, color: Color(0xFF4ADE80), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cw.workoutName,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateStr • ${cw.workoutType}',
                  style: const TextStyle(color: Color(0xFF808080), fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$mins min',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                '${cw.exercisesCompleted}/${cw.totalExercises} done',
                style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _workoutsThisMonth(Map<DateTime, bool> calendar) {
    final now = DateTime.now();
    return calendar.entries
        .where((e) => e.key.year == now.year && e.key.month == now.month && e.value)
        .length;
  }

  String _monthName(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${months[date.month - 1]} ${date.day}';
  }
}

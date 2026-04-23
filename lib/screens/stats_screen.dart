import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<WorkoutProvider>(
          builder: (context, provider, _) {
            return NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stats',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        // Quick stats row
                        Row(
                          children: [
                            Expanded(child: _buildQuickStat('🔥', '${provider.currentStreak}', 'Day Streak')),
                            const SizedBox(width: 10),
                            Expanded(child: _buildQuickStat('🏋️', '${provider.completedWorkouts.length}', 'Sessions')),
                            const SizedBox(width: 10),
                            Expanded(child: _buildQuickStat('⚡', '${provider.personalRecords.length}', 'PRs')),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Tab bar
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelColor: Colors.black,
                            unselectedLabelColor: const Color(0xFF808080),
                            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            tabs: const [
                              Tab(text: 'Overview'),
                              Tab(text: 'Body'),
                              Tab(text: 'PRs'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(provider),
                  _buildBodyTab(provider),
                  _buildPRsTab(provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickStat(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: Color(0xFF808080), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(WorkoutProvider provider) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Volume chart — derived from completed workouts in the last 7 days
        _buildSectionHeader('Volume Lifted', 'Last 7 days'),
        const SizedBox(height: 12),
        _buildVolumeChart(provider),
        const SizedBox(height: 20),

        // Muscle group progress
        _buildSectionHeader('Muscle Groups', 'Training focus'),
        const SizedBox(height: 12),
        ...provider.muscleGroups.map((mg) => _buildMuscleGroupRow(mg)),
        const SizedBox(height: 20),

        // Workout frequency this week — from workoutCalendar
        _buildSectionHeader('Workout Frequency', 'This week'),
        const SizedBox(height: 12),
        _buildFrequencyBar(provider),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildBodyTab(WorkoutProvider provider) {
    final history = provider.bodyWeightHistory;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Current weight card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Weight', style: TextStyle(color: Color(0xFF808080), fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${provider.userStats?.bodyWeight.toStringAsFixed(1) ?? '—'}',
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6, left: 4),
                        child: Text('lbs', style: TextStyle(color: Color(0xFF808080), fontSize: 16)),
                      ),
                    ],
                  ),
                  if (history.length >= 2)
                    _buildWeightChange(history),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showLogWeightDialog(context, provider),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Log weight',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _buildSectionHeader('Weight History', '12 weeks'),
        const SizedBox(height: 12),
        _buildWeightChart(history),
        const SizedBox(height: 20),

        // History list
        _buildSectionHeader('Log', 'All entries'),
        const SizedBox(height: 12),
        ...history.reversed.take(8).map((entry) => _buildWeightLogItem(entry)),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildPRsTab(WorkoutProvider provider) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A2A1A), Color(0xFF0A1A0A)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF4ADE80).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Records',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${provider.personalRecords.length} records tracked',
                    style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...provider.personalRecords.map((pr) => _buildPRCard(pr)),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(subtitle, style: const TextStyle(color: Color(0xFF808080), fontSize: 13)),
      ],
    );
  }

  Widget _buildMuscleGroupRow(MuscleGroup mg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(mg.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(mg.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A3A2A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          mg.status,
                          style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: mg.progress,
                      backgroundColor: const Color(0xFF2A2A2A),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeChart(WorkoutProvider provider) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // Build actual volume from last 7 days
    final now = DateTime.now();
    final weekdayValues = List<double>.filled(7, 0.0);
    for (final cw in provider.completedWorkouts) {
      final diff = now.difference(cw.completedAt).inDays;
      if (diff < 7) {
        // weekday: Mon=0..Sun=6
        final idx = (cw.completedAt.weekday - 1) % 7;
        weekdayValues[idx] = (weekdayValues[idx] + cw.volumeLifted);
      }
    }
    // Normalise to 0..1 range
    final maxVol = weekdayValues.reduce((a, b) => a > b ? a : b);
    final normalised = maxVol > 0
        ? weekdayValues.map((v) => v / maxVol).toList()
        : weekdayValues;

    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300 + i * 50),
                    width: 24,
                    height: (normalised[i] * 80).clamp(4.0, 80.0),
                    decoration: BoxDecoration(
                      color: normalised[i] > 0
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(days[i], style: const TextStyle(color: Color(0xFF808080), fontSize: 11)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFrequencyBar(WorkoutProvider provider) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    // Check which day of the current week had a completed workout
    final worked = List<bool>.generate(7, (i) {
      // Monday of this week
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final day = monday.add(Duration(days: i));
      return provider.completedWorkouts.any((cw) {
        return cw.completedAt.year == day.year &&
            cw.completedAt.month == day.month &&
            cw.completedAt.day == day.day;
      }) || (provider.userStats?.workoutCalendar.entries.any((e) =>
            e.key.year == day.year &&
            e.key.month == day.month &&
            e.key.day == day.day &&
            e.value) ?? false);
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          return Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: worked[i] ? const Color(0xFF4ADE80) : const Color(0xFF2A2A2A),
                  shape: BoxShape.circle,
                ),
                child: worked[i]
                    ? const Icon(Icons.check, size: 16, color: Colors.black)
                    : null,
              ),
              const SizedBox(height: 6),
              Text(labels[i], style: const TextStyle(color: Color(0xFF808080), fontSize: 12)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildWeightChart(List<BodyWeightEntry> history) {
    if (history.isEmpty) return const SizedBox.shrink();
    final weights = history.map((e) => e.weight).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b) - 2;
    final maxW = weights.reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        painter: _LineChartPainter(
          values: weights,
          minValue: minW,
          maxValue: maxW,
          color: const Color(0xFF4ADE80),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildWeightLogItem(BodyWeightEntry entry) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final d = entry.date;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '${months[d.month - 1]} ${d.day}',
            style: const TextStyle(color: Color(0xFF808080), fontSize: 14),
          ),
          const Spacer(),
          Text(
            '${entry.weight.toStringAsFixed(1)} lbs',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChange(List<BodyWeightEntry> history) {
    final latest = history.last.weight;
    final prev = history[history.length - 2].weight;
    final diff = latest - prev;
    final isDown = diff <= 0;
    return Row(
      children: [
        Icon(
          isDown ? Icons.trending_down : Icons.trending_up,
          color: isDown ? const Color(0xFF4ADE80) : Colors.redAccent,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '${diff.abs().toStringAsFixed(1)} lbs from last month',
          style: TextStyle(
            color: isDown ? const Color(0xFF4ADE80) : Colors.redAccent,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildPRCard(PersonalRecord pr) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final d = pr.achievedAt;
    final dateStr = '${months[d.month - 1]} ${d.day}, ${d.year}';
    final weightStr = pr.weight > 0
        ? '${pr.weight.toStringAsFixed(1)} kg × ${pr.reps} reps'
        : '${pr.reps} reps (bodyweight)';

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
            child: const Center(child: Text('🏆', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pr.exerciseName,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(weightStr, style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 13)),
              ],
            ),
          ),
          Text(dateStr, style: const TextStyle(color: Color(0xFF808080), fontSize: 12)),
        ],
      ),
    );
  }

  void _showLogWeightDialog(BuildContext context, WorkoutProvider provider) {
    final controller = TextEditingController(
      text: provider.userStats?.bodyWeight.toStringAsFixed(1) ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Body Weight', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white, fontSize: 20),
          decoration: const InputDecoration(
            suffixText: 'lbs',
            suffixStyle: TextStyle(color: Color(0xFF808080)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4ADE80))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4ADE80))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF808080))),
          ),
          ElevatedButton(
            onPressed: () {
              final w = double.tryParse(controller.text);
              if (w != null) {
                provider.logBodyWeight(w);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final double minValue;
  final double maxValue;
  final Color color;

  _LineChartPainter({
    required this.values,
    required this.minValue,
    required this.maxValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - ((values[i] - minValue) / (maxValue - minValue)) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) / (values.length - 1) * size.width;
        final prevY = size.height - ((values[i - 1] - minValue) / (maxValue - minValue)) * size.height;
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()..color = color..style = PaintingStyle.fill;
    final dotBg = Paint()..color = const Color(0xFF1A1A1A)..style = PaintingStyle.fill;
    for (int i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - ((values[i] - minValue) / (maxValue - minValue)) * size.height;
      canvas.drawCircle(Offset(x, y), 5, dotBg);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_progress_item.dart';

class WorkoutInProgressScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutInProgressScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutInProgressScreen> createState() => _WorkoutInProgressScreenState();
}

class _WorkoutInProgressScreenState extends State<WorkoutInProgressScreen> {
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _elapsedTime += const Duration(seconds: 1));
      context.read<WorkoutProvider>().updateWorkoutDuration(_elapsedTime);
    });
  }

  String _formatDuration(Duration duration) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(duration.inHours);
    final m = two(duration.inMinutes.remainder(60));
    final s = two(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _showRestTimerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _RestTimerDialog(),
    );
  }

  void _finishWorkout() {
    showDialog(
      context: context,
      builder: (ctx) {
        final provider = ctx.read<WorkoutProvider>();
        final exercises = provider.currentWorkout?.exercises ?? widget.workout.exercises;
        final completed = exercises.where((e) => e.isCompleted).length;
        final total = exercises.length;

        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                'Workout Complete!',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.workout.name,
                style: const TextStyle(color: Color(0xFF808080), fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryStat('⏱', _formatDuration(_elapsedTime), 'Duration'),
                  _buildSummaryStat('✅', '$completed/$total', 'Exercises'),
                ],
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                provider.finishWorkout();
                Navigator.pop(ctx);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Finish & Save', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Color(0xFF808080), fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<WorkoutProvider>(
          builder: (context, provider, _) {
            final exercises = provider.currentWorkout?.exercises ?? widget.workout.exercises;
            final completedCount = exercises.where((e) => e.isCompleted).length;
            final progress = exercises.isEmpty ? 0.0 : completedCount / exercises.length;

            // Find next uncompleted exercise
            final nextExercise = exercises.firstWhere(
              (e) => !e.isCompleted,
              orElse: () => exercises.last,
            );
            final allDone = exercises.every((e) => e.isCompleted);

            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A1A1A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _showRestTimerDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.timer_outlined, color: Color(0xFF4ADE80), size: 16),
                              SizedBox(width: 4),
                              Text('Rest timer', style: TextStyle(color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _finishWorkout,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Finish',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Timer and progress
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: [
                      Text(
                        _formatDuration(_elapsedTime),
                        style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.workout.type} • In progress',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF808080)),
                      ),
                      const SizedBox(height: 16),
                      // Progress bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$completedCount of ${exercises.length} exercises',
                                style: const TextStyle(color: Color(0xFF808080), fontSize: 13),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: const Color(0xFF2A2A2A),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Exercise list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    itemCount: exercises.length + 1,
                    itemBuilder: (context, index) {
                      if (index == exercises.length) {
                        return GestureDetector(
                          onTap: () {/* Could open add exercise screen */},
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add_circle_outline, color: Color(0xFF4ADE80), size: 22),
                                SizedBox(width: 12),
                                Text(
                                  'Add exercise',
                                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      final exercise = exercises[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ExerciseProgressItem(
                          exercise: exercise,
                          onTap: () => provider.toggleExerciseCompletion(exercise.id),
                        ),
                      );
                    },
                  ),
                ),

                // Next exercise bar
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  decoration: const BoxDecoration(color: Color(0xFF111111)),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: allDone ? const Color(0xFF1A3A2A) : const Color(0xFF2A2A2A),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: allDone
                                ? const Icon(Icons.check, color: Color(0xFF4ADE80), size: 22)
                                : const Text('📊', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                allDone ? 'All done!' : nextExercise.name,
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                allDone ? 'Tap Finish to save your workout' : 'Up next',
                                style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        if (!allDone)
                          GestureDetector(
                            onTap: () => provider.toggleExerciseCompletion(nextExercise.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Text('Skip', style: TextStyle(color: Colors.white, fontSize: 13)),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                                ],
                              ),
                            ),
                          ),
                        if (allDone)
                          GestureDetector(
                            onTap: _finishWorkout,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4ADE80),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Finish', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RestTimerDialog extends StatefulWidget {
  @override
  State<_RestTimerDialog> createState() => _RestTimerDialogState();
}

class _RestTimerDialogState extends State<_RestTimerDialog> {
  int _selectedSeconds = 90;
  int _remaining = 90;
  Timer? _timer;
  bool _running = false;

  final List<int> _presets = [30, 60, 90, 120, 180];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStop() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      if (_remaining <= 0) _remaining = _selectedSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _remaining--;
          if (_remaining <= 0) {
            _timer?.cancel();
            _running = false;
          }
        });
      });
      setState(() => _running = true);
    }
  }

  String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remaining / _selectedSeconds;
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rest Timer', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 8,
                    backgroundColor: const Color(0xFF2A2A2A),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
                  ),
                  Text(
                    _format(_remaining),
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Presets
            Wrap(
              spacing: 8,
              children: _presets.map((s) {
                final isSelected = _selectedSeconds == s;
                return GestureDetector(
                  onTap: () {
                    _timer?.cancel();
                    setState(() {
                      _selectedSeconds = s;
                      _remaining = s;
                      _running = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${s}s',
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _timer?.cancel();
                      setState(() {
                        _remaining = _selectedSeconds;
                        _running = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.replay, color: Colors.white, size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _startStop,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _running ? const Color(0xFF3A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          _running ? 'Pause' : 'Start',
                          style: TextStyle(
                            color: _running ? Colors.redAccent : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

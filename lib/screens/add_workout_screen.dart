import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _nameController = TextEditingController();
  final _dayController = TextEditingController();
  String _selectedType = 'Push day';
  int _duration = 60;
  final List<_ExerciseFormData> _exercises = [];

  final List<String> _workoutTypes = [
    'Push day', 'Pull day', 'Leg day', 'Cardio', 'Full body', 'Upper body', 'Lower body', 'Core',
  ];

  final List<String> _dayOptions = [
    'Mondays', 'Tuesdays', 'Wednesdays', 'Thursdays', 'Fridays', 'Saturdays', 'Sundays', 'Any day',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dayController.dispose();
    for (final e in _exercises) e.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                  const Expanded(
                    child: Text(
                      'New Workout',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: _saveWorkout,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Workout name
                  _buildLabel('Workout Name'),
                  const SizedBox(height: 8),
                  _buildTextField(_nameController, 'e.g. Chest + Tricep'),
                  const SizedBox(height: 20),

                  // Type
                  _buildLabel('Type'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _workoutTypes.map((type) {
                      final selected = _selectedType == type;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedType = type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? Colors.white : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: selected ? Colors.black : const Color(0xFFB0B0B0),
                              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Day
                  _buildLabel('Day'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _dayOptions.contains(_dayController.text) ? _dayController.text : _dayOptions.first,
                        dropdownColor: const Color(0xFF1A1A1A),
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF808080)),
                        isExpanded: true,
                        items: _dayOptions.map((d) {
                          return DropdownMenuItem(value: d, child: Text(d));
                        }).toList(),
                        onChanged: (v) => setState(() => _dayController.text = v ?? _dayOptions.first),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Duration
                  _buildLabel('Duration (minutes): $_duration'),
                  Slider(
                    value: _duration.toDouble(),
                    min: 15,
                    max: 120,
                    divisions: 21,
                    activeColor: const Color(0xFF4ADE80),
                    inactiveColor: const Color(0xFF2A2A2A),
                    label: '$_duration min',
                    onChanged: (v) => setState(() => _duration = v.toInt()),
                  ),
                  const SizedBox(height: 20),

                  // Exercises header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('Exercises (${_exercises.length})'),
                      GestureDetector(
                        onTap: () => setState(() => _exercises.add(_ExerciseFormData())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3A2A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add, color: Color(0xFF4ADE80), size: 16),
                              SizedBox(width: 4),
                              Text('Add', style: TextStyle(color: Color(0xFF4ADE80), fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ..._exercises.asMap().entries.map((entry) {
                    return _buildExerciseForm(entry.key, entry.value);
                  }),

                  if (_exercises.isEmpty)
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF2A2A2A), style: BorderStyle.solid),
                      ),
                      child: const Center(
                        child: Text(
                          'Tap "Add" to add exercises',
                          style: TextStyle(color: Color(0xFF606060), fontSize: 14),
                        ),
                      ),
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF606060)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildExerciseForm(int index, _ExerciseFormData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Exercise ${index + 1}',
                style: const TextStyle(color: Color(0xFF808080), fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() {
                  data.dispose();
                  _exercises.removeAt(index);
                }),
                child: const Icon(Icons.close, color: Color(0xFF606060), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: data.nameController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Exercise name',
              hintStyle: TextStyle(color: Color(0xFF606060)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 16),
          Row(
            children: [
              Expanded(child: _buildNumberField(data.setsController, 'Sets')),
              const SizedBox(width: 10),
              Expanded(child: _buildNumberField(data.repsController, 'Reps')),
              const SizedBox(width: 10),
              Expanded(child: _buildNumberField(data.weightController, 'kg')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF808080), fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true),
          ),
        ),
      ],
    );
  }

  void _saveWorkout() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a workout name'),
          backgroundColor: Color(0xFF1A1A1A),
        ),
      );
      return;
    }

    final exercises = _exercises.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      return Exercise(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}_$i',
        name: e.nameController.text.trim().isEmpty ? 'Exercise ${i + 1}' : e.nameController.text.trim(),
        sets: int.tryParse(e.setsController.text) ?? 3,
        reps: int.tryParse(e.repsController.text) ?? 10,
        weight: double.tryParse(e.weightController.text) ?? 0.0,
      );
    }).toList();

    final workout = Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      day: _dayController.text.isEmpty ? _dayOptions.first : _dayController.text,
      duration: _duration,
      type: _selectedType,
      exercises: exercises,
    );

    context.read<WorkoutProvider>().addWorkout(workout);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Workout "${workout.name}" added!'),
        backgroundColor: const Color(0xFF1A3A2A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ExerciseFormData {
  final nameController = TextEditingController();
  final setsController = TextEditingController(text: '3');
  final repsController = TextEditingController(text: '10');
  final weightController = TextEditingController(text: '0');

  void dispose() {
    nameController.dispose();
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
  }
}

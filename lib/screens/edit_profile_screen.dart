import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _targetWeightController;
  String _selectedGoal = 'Muscle Gain & Strength';
  String _selectedGoalEmoji = '🎯';

  final List<Map<String, String>> _goalOptions = [
    {'emoji': '🎯', 'label': 'Muscle Gain & Strength'},
    {'emoji': '🔥', 'label': 'Fat Loss & Toning'},
    {'emoji': '🏃', 'label': 'Endurance & Cardio'},
    {'emoji': '⚡', 'label': 'Athletic Performance'},
    {'emoji': '🧘', 'label': 'General Fitness & Health'},
    {'emoji': '💪', 'label': 'Powerlifting & PRs'},
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<WorkoutProvider>().userProfile;
    _nameController = TextEditingController(text: profile.name);
    _bioController = TextEditingController(text: profile.bio);
    _ageController = TextEditingController(text: '${profile.age}');
    _heightController = TextEditingController(text: profile.height.toStringAsFixed(0));
    _targetWeightController = TextEditingController(text: profile.targetWeight.toStringAsFixed(0));
    _selectedGoal = profile.goal;
    _selectedGoalEmoji = profile.goalEmoji;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: Color(0xFF2A1A1A),
        ),
      );
      return;
    }

    final updated = UserProfile(
      name: name,
      bio: _bioController.text.trim().isEmpty
          ? 'Fitness Enthusiast'
          : _bioController.text.trim(),
      goal: _selectedGoal,
      goalEmoji: _selectedGoalEmoji,
      targetWeight: double.tryParse(_targetWeightController.text) ?? 200.0,
      age: int.tryParse(_ageController.text) ?? 24,
      height: double.tryParse(_heightController.text) ?? 178.0,
    );

    context.read<WorkoutProvider>().updateProfile(updated);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated ✓'),
        backgroundColor: const Color(0xFF1A3A2A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Edit Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                children: [
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF1A1A1A), width: 3),
                          ),
                          child: const Center(
                            child: Text('💪', style: TextStyle(fontSize: 38)),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 15, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Name
                  _buildLabel('Full Name'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Your name',
                    icon: Icons.person_outline,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 18),

                  // Bio
                  _buildLabel('Bio / Tagline'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _bioController,
                    hint: 'e.g. Fitness Enthusiast • PPL',
                    icon: Icons.edit_outlined,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 18),

                  // Age + Height row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Age'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _ageController,
                              hint: '24',
                              icon: Icons.cake_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Height (cm)'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _heightController,
                              hint: '178',
                              icon: Icons.height,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Target Weight
                  _buildLabel('Target Weight (lbs)'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _targetWeightController,
                    hint: '200',
                    icon: Icons.track_changes_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 24),

                  // Goal
                  _buildLabel('Fitness Goal'),
                  const SizedBox(height: 12),
                  ...List.generate(_goalOptions.length, (i) {
                    final option = _goalOptions[i];
                    final isSelected = _selectedGoal == option['label'];
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedGoal = option['label']!;
                        _selectedGoalEmoji = option['emoji']!;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1A3A2A)
                              : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4ADE80)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(option['emoji']!, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                option['label']!,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFFB0B0B0),
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
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
      style: const TextStyle(
        color: Color(0xFFB0B0B0),
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF505050)),
          prefixIcon: Icon(icon, color: const Color(0xFF505050), size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

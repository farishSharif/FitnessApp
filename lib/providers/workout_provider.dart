import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutProvider with ChangeNotifier {
  List<Workout> _workouts = [];
  List<MuscleGroup> _muscleGroups = [];
  UserStats? _userStats;
  Workout? _currentWorkout;
  bool _isWorkoutInProgress = false;
  Duration _workoutDuration = Duration.zero;

  List<CompletedWorkout> _completedWorkouts = [];
  List<BodyWeightEntry> _bodyWeightHistory = [];
  List<PersonalRecord> _personalRecords = [];
  List<ChatMessage> _chatMessages = [];
  UserProfile _userProfile = UserProfile(
    name: 'Farish Sharif',
    bio: 'Fitness Enthusiast • Push/Pull/Cardio',
    goal: 'Muscle Gain & Strength',
    goalEmoji: '🎯',
    targetWeight: 200.0,
    age: 24,
    height: 178.0,
  );

  int _currentExerciseIndex = 0;

  List<Workout> get workouts => _workouts;
  List<MuscleGroup> get muscleGroups => _muscleGroups;
  UserStats? get userStats => _userStats;
  Workout? get currentWorkout => _currentWorkout;
  bool get isWorkoutInProgress => _isWorkoutInProgress;
  Duration get workoutDuration => _workoutDuration;
  List<CompletedWorkout> get completedWorkouts => _completedWorkouts;
  List<BodyWeightEntry> get bodyWeightHistory => _bodyWeightHistory;
  List<PersonalRecord> get personalRecords => _personalRecords;
  List<ChatMessage> get chatMessages => _chatMessages;
  int get currentExerciseIndex => _currentExerciseIndex;
  UserProfile get userProfile => _userProfile;

  int get currentStreak {
    if (_userStats == null) return 0;
    final calendar = _userStats!.workoutCalendar;
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final hasWorkout = calendar.entries
          .where((e) =>
              e.key.year == date.year &&
              e.key.month == date.month &&
              e.key.day == date.day)
          .any((e) => e.value);
      if (hasWorkout) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  WorkoutProvider() {
    _initializeData();
  }

  void _initializeData() {
    _workouts = [
      Workout(
        id: '1',
        name: 'Chest + Tricep',
        day: 'Fridays',
        duration: 60,
        type: 'Push day',
        exercises: [
          Exercise(id: '1', name: 'Barbell Bench Press', sets: 5, reps: 8, weight: 80.0),
          Exercise(id: '2', name: 'Barbell Military Press', sets: 3, reps: 10, weight: 50.0),
          Exercise(id: '3', name: 'Dumbbell Incline Press', sets: 3, reps: 12, weight: 30.0),
          Exercise(id: '4', name: 'Dumbbell Lateral Raises', sets: 3, reps: 15, weight: 12.5),
          Exercise(id: '5', name: 'Dumbbell Tricep Extensions', sets: 3, reps: 12, weight: 20.0),
        ],
      ),
      Workout(
        id: '2',
        name: 'Back + Bicep + Legs',
        day: 'Mondays',
        duration: 75,
        type: 'Pull day',
        exercises: [
          Exercise(id: '6', name: 'Deadlifts', sets: 5, reps: 5, weight: 120.0),
          Exercise(id: '7', name: 'Pull-ups', sets: 4, reps: 8, weight: 0.0, type: ExerciseType.bodyweight),
          Exercise(id: '8', name: 'Barbell Rows', sets: 4, reps: 10, weight: 70.0),
          Exercise(id: '9', name: 'Barbell Curls', sets: 3, reps: 12, weight: 40.0),
          Exercise(id: '10', name: 'Leg Press', sets: 4, reps: 12, weight: 140.0),
        ],
      ),
      Workout(
        id: '3',
        name: 'Cardio & Core',
        day: 'Wednesdays',
        duration: 45,
        type: 'Cardio',
        exercises: [
          Exercise(id: '11', name: 'Treadmill Run', sets: 1, reps: 1, weight: 0.0, type: ExerciseType.cardio, notes: '5 km • 5:40 min/km'),
          Exercise(id: '12', name: 'Pull-ups (Chins)', sets: 4, reps: 8, weight: 0.0, type: ExerciseType.bodyweight),
          Exercise(id: '13', name: 'Planks', sets: 3, reps: 1, weight: 0.0, type: ExerciseType.time, notes: '3 x 30 sec'),
          Exercise(id: '14', name: 'Bicycle Crunches', sets: 3, reps: 20, weight: 0.0, type: ExerciseType.bodyweight),
          Exercise(id: '15', name: 'Stationary Bike', sets: 1, reps: 1, weight: 0.0, type: ExerciseType.cardio, notes: '10 min'),
        ],
      ),
    ];

    _muscleGroups = [
      MuscleGroup(name: 'Front Delts', icon: '💪', status: 'Growing', currentReps: 0, targetIncrease: 6, totalReps: 18, progress: 0.3),
      MuscleGroup(name: 'Chest', icon: '🏋️', status: 'Growing', currentReps: 0, targetIncrease: 6, totalReps: 18, progress: 0.4),
      MuscleGroup(name: 'Side Delts', icon: '💪', status: 'Growing', currentReps: 0, targetIncrease: 6, totalReps: 18, progress: 0.2),
      MuscleGroup(name: 'Back', icon: '🔙', status: 'Maintaining', currentReps: 0, targetIncrease: 4, totalReps: 16, progress: 0.6),
      MuscleGroup(name: 'Biceps', icon: '💪', status: 'Growing', currentReps: 0, targetIncrease: 5, totalReps: 15, progress: 0.5),
      MuscleGroup(name: 'Legs', icon: '🦵', status: 'Maintaining', currentReps: 0, targetIncrease: 8, totalReps: 24, progress: 0.35),
    ];

    _userStats = UserStats(
      bodyWeight: 190.0,
      lastWeightUpdate: DateTime.now().subtract(const Duration(minutes: 31)),
      volumeLifted: 3200.0,
      period: 'Last 7 days',
      workoutCalendar: _generateWorkoutCalendar(),
    );

    _bodyWeightHistory = _generateBodyWeightHistory();
    _personalRecords = _generatePersonalRecords();
    _completedWorkouts = _generateCompletedWorkouts();
    _initializeChatMessages();

    notifyListeners();
  }

  List<BodyWeightEntry> _generateBodyWeightHistory() {
    final now = DateTime.now();
    final weights = [195.0, 194.0, 193.5, 193.0, 192.0, 191.5, 191.0, 191.0, 190.5, 190.0, 190.0, 189.5];
    return List.generate(12, (i) {
      return BodyWeightEntry(
        date: DateTime(now.year, now.month - (11 - i), now.day),
        weight: weights[i],
      );
    });
  }

  List<PersonalRecord> _generatePersonalRecords() {
    final now = DateTime.now();
    return [
      PersonalRecord(exerciseName: 'Barbell Bench Press', weight: 100.0, reps: 5, achievedAt: now.subtract(const Duration(days: 7))),
      PersonalRecord(exerciseName: 'Deadlifts', weight: 140.0, reps: 3, achievedAt: now.subtract(const Duration(days: 14))),
      PersonalRecord(exerciseName: 'Barbell Rows', weight: 80.0, reps: 8, achievedAt: now.subtract(const Duration(days: 21))),
      PersonalRecord(exerciseName: 'Pull-ups', weight: 0.0, reps: 12, achievedAt: now.subtract(const Duration(days: 3))),
      PersonalRecord(exerciseName: 'Barbell Military Press', weight: 60.0, reps: 6, achievedAt: now.subtract(const Duration(days: 10))),
    ];
  }

  List<CompletedWorkout> _generateCompletedWorkouts() {
    final now = DateTime.now();
    return [
      CompletedWorkout(id: 'c1', workoutName: 'Chest + Tricep', workoutType: 'Push day', completedAt: now.subtract(const Duration(days: 1)), duration: const Duration(minutes: 62), volumeLifted: 3150, exercisesCompleted: 5, totalExercises: 5),
      CompletedWorkout(id: 'c2', workoutName: 'Back + Bicep + Legs', workoutType: 'Pull day', completedAt: now.subtract(const Duration(days: 3)), duration: const Duration(minutes: 78), volumeLifted: 4200, exercisesCompleted: 4, totalExercises: 5),
      CompletedWorkout(id: 'c3', workoutName: 'Cardio & Core', workoutType: 'Cardio', completedAt: now.subtract(const Duration(days: 5)), duration: const Duration(minutes: 47), volumeLifted: 0, exercisesCompleted: 5, totalExercises: 5),
      CompletedWorkout(id: 'c4', workoutName: 'Chest + Tricep', workoutType: 'Push day', completedAt: now.subtract(const Duration(days: 8)), duration: const Duration(minutes: 59), volumeLifted: 3050, exercisesCompleted: 5, totalExercises: 5),
      CompletedWorkout(id: 'c5', workoutName: 'Back + Bicep + Legs', workoutType: 'Pull day', completedAt: now.subtract(const Duration(days: 10)), duration: const Duration(minutes: 72), volumeLifted: 4000, exercisesCompleted: 5, totalExercises: 5),
    ];
  }

  void _initializeChatMessages() {
    _chatMessages = [
      ChatMessage(
        id: '0',
        content: "Hey! I'm your AI fitness coach 🏋️ I'm here to help you crush your goals. Ask me anything about workouts, nutrition, or recovery!",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  Map<DateTime, bool> _generateWorkoutCalendar() {
    final calendar = <DateTime, bool>{};
    final now = DateTime.now();
    for (int month = 0; month < 3; month++) {
      final date = DateTime(now.year, now.month - month, 1);
      final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
      for (int day = 1; day <= daysInMonth; day++) {
        final currentDate = DateTime(date.year, date.month, day);
        calendar[currentDate] =
            (day % 3 == 0 || day % 7 == 0) && currentDate.isBefore(now);
      }
    }
    return calendar;
  }

  void startWorkout(Workout workout) {
    _currentWorkout = Workout(
      id: workout.id,
      name: workout.name,
      day: workout.day,
      duration: workout.duration,
      exercises: List.from(workout.exercises),
      type: workout.type,
    );
    _isWorkoutInProgress = true;
    _workoutDuration = Duration.zero;
    _currentExerciseIndex = 0;
    notifyListeners();
  }

  void finishWorkout() {
    if (_currentWorkout != null) {
      final completed = CompletedWorkout(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        workoutName: _currentWorkout!.name,
        workoutType: _currentWorkout!.type,
        completedAt: DateTime.now(),
        duration: _workoutDuration,
        volumeLifted: _calculateVolumeLifted(_currentWorkout!.exercises),
        exercisesCompleted: _currentWorkout!.exercises.where((e) => e.isCompleted).length,
        totalExercises: _currentWorkout!.exercises.length,
      );
      _completedWorkouts.insert(0, completed);

      final today = DateTime.now();
      final todayKey = DateTime(today.year, today.month, today.day);
      final updatedCalendar = Map<DateTime, bool>.from(_userStats!.workoutCalendar);
      updatedCalendar[todayKey] = true;
      _userStats = UserStats(
        bodyWeight: _userStats!.bodyWeight,
        lastWeightUpdate: _userStats!.lastWeightUpdate,
        volumeLifted: _userStats!.volumeLifted + completed.volumeLifted,
        period: _userStats!.period,
        workoutCalendar: updatedCalendar,
      );
    }
    _currentWorkout = null;
    _isWorkoutInProgress = false;
    _workoutDuration = Duration.zero;
    _currentExerciseIndex = 0;
    notifyListeners();
  }

  double _calculateVolumeLifted(List<Exercise> exercises) {
    double total = 0;
    for (final e in exercises) {
      if (e.type == ExerciseType.weight) {
        total += e.weight * e.sets * e.reps;
      }
    }
    return total;
  }

  void updateWorkoutDuration(Duration duration) {
    _workoutDuration = duration;
    notifyListeners();
  }

  void toggleExerciseCompletion(String exerciseId) {
    if (_currentWorkout != null) {
      final exercises = List<Exercise>.from(_currentWorkout!.exercises);
      final idx = exercises.indexWhere((e) => e.id == exerciseId);
      if (idx != -1) {
        exercises[idx] = exercises[idx].copyWith(isCompleted: !exercises[idx].isCompleted);
        _currentWorkout = Workout(
          id: _currentWorkout!.id,
          name: _currentWorkout!.name,
          day: _currentWorkout!.day,
          duration: _currentWorkout!.duration,
          exercises: exercises,
          type: _currentWorkout!.type,
        );
        final completedCount = exercises.where((e) => e.isCompleted).length;
        _currentExerciseIndex = completedCount < exercises.length ? completedCount : exercises.length - 1;
        notifyListeners();
      }
    }
  }

  void addWorkout(Workout workout) {
    _workouts.add(workout);
    notifyListeners();
  }

  void deleteWorkout(String id) {
    _workouts.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  void logBodyWeight(double weight) {
    _bodyWeightHistory.add(BodyWeightEntry(date: DateTime.now(), weight: weight));
    _userStats = UserStats(
      bodyWeight: weight,
      lastWeightUpdate: DateTime.now(),
      volumeLifted: _userStats?.volumeLifted ?? 0,
      period: _userStats?.period ?? 'Last 7 days',
      workoutCalendar: _userStats?.workoutCalendar ?? {},
    );
    notifyListeners();
  }

  void updateProfile(UserProfile updated) {
    _userProfile = updated;
    notifyListeners();
  }

  void addChatMessage(String content, bool isUser) {
    _chatMessages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: isUser,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  String generateCoachResponse(String userMessage) {
    final msg = userMessage.toLowerCase();

    if (msg.contains('bench') || msg.contains('chest')) {
      return "Great question! For bench press, focus on:\n\n• Keep your shoulder blades retracted\n• Drive your feet into the ground\n• Control the descent — 2 seconds down\n• Aim for progressive overload each week 💪\n\nYou're currently doing 80kg for 5×8. Consider bumping to 82.5kg next session!";
    } else if (msg.contains('protein') || msg.contains('diet') || msg.contains('nutrition') || msg.contains('eat')) {
      return "Nutrition is 70% of your results! Here's my advice:\n\n• Aim for **1g protein per lb** of body weight (190g for you)\n• Prioritize whole foods: chicken, eggs, fish, legumes\n• Eat 2-3 hours before training\n• Stay hydrated — 2-3L of water daily 💧\n\nWant a sample meal plan?";
    } else if (msg.contains('rest') || msg.contains('recover') || msg.contains('sleep')) {
      return "Recovery is where the gains happen! 😴\n\n• Aim for **7-9 hours** of sleep per night\n• Rest 48-72 hours between training the same muscle group\n• Active recovery (walking, stretching) on rest days\n• Consider foam rolling post-workout\n\nYour schedule looks solid — 3 days on works well!";
    } else if (msg.contains('cardio') || msg.contains('run') || msg.contains('endurance')) {
      return "Cardio tips for you:\n\n• Keep cardio **separate** from heavy lifting sessions\n• 2-3x per week is plenty for fat loss while maintaining muscle\n• Zone 2 cardio (conversational pace) is most effective for fat oxidation\n• Your 5km runs are great — try to maintain that pace! 🏃\n\nConsider adding HIIT once a week for extra calorie burn.";
    } else if (msg.contains('motivation') || msg.contains('tired') || msg.contains('lazy')) {
      return "We all feel that way sometimes. Here's what works:\n\n• **Just start** — commit to 10 minutes, you'll usually finish\n• Track your progress (you're already doing this! 📊)\n• Remember your *why* — why did you start?\n• Your streak is looking great, don't break it!\n\nYou've got this. The hardest part is walking through the gym door 🚪💪";
    } else if (msg.contains('weight loss') || msg.contains('fat') || msg.contains('cut')) {
      return "For fat loss while preserving muscle:\n\n• Create a **300-500 cal deficit** — not too aggressive\n• Keep protein HIGH (190g+ per day at your weight)\n• Maintain your lifting intensity\n• Add 1-2 cardio sessions per week\n• Weigh yourself daily, track the **weekly average**\n\nYou're at 190 lbs — what's your target weight?";
    } else if (msg.contains('deadlift')) {
      return "Deadlifts are king! 👑 Some form cues:\n\n• Hip hinge, not a squat — push the floor away\n• Bar stays close to your body throughout\n• Lock out with glutes, not lower back\n• Brace your core before each rep\n\nYou're pulling 120kg for 5×5 — impressive! Ready to try 125kg?";
    } else if (msg.contains('hi') || msg.contains('hello') || msg.contains('hey')) {
      return "Hey there! 💪 Ready to crush your goals today?\n\nI can help you with:\n• **Workout advice** — form, programming, exercises\n• **Nutrition** — protein, meal timing, supplements\n• **Recovery** — sleep, rest days, injury prevention\n• **Motivation** — when you need a push\n\nWhat's on your mind?";
    } else if (msg.contains('supplement') || msg.contains('creatine') || msg.contains('protein powder')) {
      return "Supplement advice:\n\n• **Creatine** — 5g/day, most studied supplement for strength 💯\n• **Protein powder** — use to hit daily protein goals, not replace food\n• **Caffeine** — great pre-workout, but don't overdo it\n• **Vitamin D** — most people are deficient, huge health benefits\n\nThese 4 are evidence-backed. Everything else is mostly marketing 😄";
    } else {
      return "That's a great question! As your AI coach, I'd recommend:\n\n• Focus on **consistency** over perfection\n• Progressive overload is the key to gains\n• Track everything — what gets measured, gets managed\n• Listen to your body — rest when needed\n\nFeel free to ask me more specific questions about your workouts, nutrition, or recovery! 🏋️‍♂️";
    }
  }
}

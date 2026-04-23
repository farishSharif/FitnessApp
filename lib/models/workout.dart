class Workout {
  final String id;
  final String name;
  final String day;
  final int duration; // in minutes
  final List<Exercise> exercises;
  final String type; // e.g., "Push day", "Cardio"

  Workout({
    required this.id,
    required this.name,
    required this.day,
    required this.duration,
    required this.exercises,
    required this.type,
  });
}

class Exercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final double weight; // in kg
  final String? notes;
  final bool isCompleted;
  final ExerciseType type;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    this.notes,
    this.isCompleted = false,
    this.type = ExerciseType.weight,
  });

  Exercise copyWith({
    String? id,
    String? name,
    int? sets,
    int? reps,
    double? weight,
    String? notes,
    bool? isCompleted,
    ExerciseType? type,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      type: type ?? this.type,
    );
  }
}

enum ExerciseType {
  weight,
  cardio,
  bodyweight,
  time,
}

class MuscleGroup {
  final String name;
  final String icon;
  final String status; // "Growing", "Maintaining", etc.
  final int currentReps;
  final int targetIncrease;
  final int totalReps;
  final double progress; // 0.0 to 1.0

  MuscleGroup({
    required this.name,
    required this.icon,
    required this.status,
    required this.currentReps,
    required this.targetIncrease,
    required this.totalReps,
    required this.progress,
  });
}

class UserStats {
  final double bodyWeight; // in lbs
  final DateTime lastWeightUpdate;
  final double volumeLifted; // in lbs
  final String period; // "Last 7 days", etc.
  final Map<DateTime, bool> workoutCalendar; // dates with workouts

  UserStats({
    required this.bodyWeight,
    required this.lastWeightUpdate,
    required this.volumeLifted,
    required this.period,
    required this.workoutCalendar,
  });
}

class CompletedWorkout {
  final String id;
  final String workoutName;
  final String workoutType;
  final DateTime completedAt;
  final Duration duration;
  final double volumeLifted;
  final int exercisesCompleted;
  final int totalExercises;

  CompletedWorkout({
    required this.id,
    required this.workoutName,
    required this.workoutType,
    required this.completedAt,
    required this.duration,
    required this.volumeLifted,
    required this.exercisesCompleted,
    required this.totalExercises,
  });
}

class BodyWeightEntry {
  final DateTime date;
  final double weight; // in lbs

  BodyWeightEntry({required this.date, required this.weight});
}

class PersonalRecord {
  final String exerciseName;
  final double weight;
  final int reps;
  final DateTime achievedAt;

  PersonalRecord({
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.achievedAt,
  });
}

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

class UserProfile {
  final String name;
  final String bio;
  final String goal; // e.g. "Muscle Gain & Strength"
  final String goalEmoji;
  final double targetWeight; // in lbs
  final int age;
  final double height; // in cm

  UserProfile({
    required this.name,
    required this.bio,
    required this.goal,
    required this.goalEmoji,
    required this.targetWeight,
    required this.age,
    required this.height,
  });

  UserProfile copyWith({
    String? name,
    String? bio,
    String? goal,
    String? goalEmoji,
    double? targetWeight,
    int? age,
    double? height,
  }) {
    return UserProfile(
      name: name ?? this.name,
      bio: bio ?? this.bio,
      goal: goal ?? this.goal,
      goalEmoji: goalEmoji ?? this.goalEmoji,
      targetWeight: targetWeight ?? this.targetWeight,
      age: age ?? this.age,
      height: height ?? this.height,
    );
  }
}

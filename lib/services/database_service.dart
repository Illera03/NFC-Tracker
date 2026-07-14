import 'package:hive/hive.dart';
import '../models/hydration_record.dart';
import '../models/workout_record.dart';

class DatabaseService {
  static const String hydrationBoxName = 'hydration';
  static const String workoutBoxName = 'workout';

  late Box<HydrationRecord> _hydrationBox;
  late Box<WorkoutRecord> _workoutBox;

  // Inicializar Hive
  Future<void> init() async {
    _hydrationBox = await Hive.openBox<HydrationRecord>(hydrationBoxName);
    _workoutBox = await Hive.openBox<WorkoutRecord>(workoutBoxName);
  }

  // Agregar hidratación
  Future<void> addHydration(int ml, String source) async {
    final record = HydrationRecord(
      timestamp: DateTime.now(),
      ml: ml,
      source: source,
    );
    await _hydrationBox.add(record);
  }

  // Agregar entrenamiento
  Future<void> addWorkout(String type, String source) async {
    final record = WorkoutRecord(
      timestamp: DateTime.now(),
      type: type,
      source: source,
    );
    await _workoutBox.add(record);
  }

  // Obtener hidratación de hoy
  int getTodayHydration() {
    final today = DateTime.now();
    return _hydrationBox.values
        .where(
          (r) =>
              r.timestamp.year == today.year &&
              r.timestamp.month == today.month &&
              r.timestamp.day == today.day,
        )
        .fold(0, (sum, r) => sum + r.ml);
  }

  // Obtener entrenamientos de hoy
  List<WorkoutRecord> getTodayWorkouts() {
    final today = DateTime.now();
    return _workoutBox.values
        .where(
          (r) =>
              r.timestamp.year == today.year &&
              r.timestamp.month == today.month &&
              r.timestamp.day == today.day,
        )
        .toList();
  }

  // Obtener todos los registros de hidratación
  List<HydrationRecord> getAllHydration() {
    return _hydrationBox.values.toList();
  }

  // Obtener todos los entrenamientos
  List<WorkoutRecord> getAllWorkouts() {
    return _workoutBox.values.toList();
  }
}

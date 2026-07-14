import 'package:hive/hive.dart';

part 'workout_record.g.dart';

@HiveType(typeId: 1)
class WorkoutRecord {
  @HiveField(0)
  final DateTime timestamp;

  @HiveField(1)
  final String type; // 'Push', 'Pull', 'Leg', o otro tipo

  @HiveField(2)
  final String source; // 'nfc' o 'manual'

  WorkoutRecord({
    required this.timestamp,
    required this.type,
    required this.source,
  });
}

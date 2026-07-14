import 'package:hive/hive.dart';

part 'hydration_record.g.dart';

@HiveType(typeId: 0)
class HydrationRecord {
  @HiveField(0)
  final DateTime timestamp;

  @HiveField(1)
  final int ml;

  @HiveField(2)
  final String source; // 'nfc' o 'manual'

  HydrationRecord({
    required this.timestamp,
    required this.ml,
    required this.source,
  });
}

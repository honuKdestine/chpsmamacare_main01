import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'appointment.g.dart';

@HiveType(typeId: 2)
class Appointment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime dateTime;

  @HiveField(3)
  final String? notes;

  @HiveField(4)
  final String? motherRecordId;

  @HiveField(5)
  final String? soundFile;

  @HiveField(6)
  final bool isRecurring;

  @HiveField(7)
  final int? recurringIntervalDays;

  @HiveField(8)
  final DateTime createdAt;

  Appointment({
    String? id,
    required this.title,
    required this.dateTime,
    this.notes,
    this.motherRecordId,
    this.soundFile,
    this.isRecurring = false,
    this.recurringIntervalDays,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();
}

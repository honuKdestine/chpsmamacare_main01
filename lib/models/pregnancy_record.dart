import 'package:hive/hive.dart';

part 'pregnancy_record.g.dart';

@HiveType(typeId: 0)
class PregnancyRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String motherName;

  @HiveField(2)
  DateTime lastMenstrualPeriod;

  @HiveField(3)
  DateTime expectedDeliveryDate;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  List<CheckupRecord> checkups;

  @HiveField(6)
  String createdAt;
  @HiveField(7)
  String midwifeName;

  PregnancyRecord({
    required this.id,
    required this.midwifeName,
    required this.motherName,
    required this.lastMenstrualPeriod,
    required this.expectedDeliveryDate,
    this.notes,
    List<CheckupRecord>? checkups,
    DateTime? createdAt,
  }) : checkups = checkups ?? [],
       createdAt =
           createdAt?.toIso8601String() ?? DateTime.now().toIso8601String();

  // Calculate current week of pregnancy
  int get currentWeek {
    final today = DateTime.now();
    final difference = today.difference(lastMenstrualPeriod).inDays;
    return (difference / 7).floor();
  }

  // Check if pregnancy is high risk (over 35 weeks)
  bool get isHighRisk {
    return currentWeek > 35;
  }

  // Get latest checkup
  CheckupRecord? get latestCheckup {
    if (checkups.isEmpty) return null;
    checkups.sort((a, b) => b.date.compareTo(a.date));
    return checkups.first;
  }
}

@HiveType(typeId: 1)
class CheckupRecord {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String notes;

  @HiveField(3)
  List<String> dangerSigns;

  @HiveField(4)
  double? weight;

  @HiveField(5)
  String? bloodPressure;

  @HiveField(6)
  int? heartRate;

  CheckupRecord({
    required this.id,
    required this.date,
    required this.notes,
    List<String>? dangerSigns,
    this.weight,
    this.bloodPressure,
    this.heartRate,
  }) : dangerSigns = dangerSigns ?? [];

  bool get hasDangerSigns => dangerSigns.isNotEmpty;
}

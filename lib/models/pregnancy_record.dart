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
  DateTime createdAt;
  @HiveField(7)
  String midwifeName;

  @HiveField(8)
  int age;

  @HiveField(9)
  String phone;

  @HiveField(10)
  String address;

  @HiveField(11)
  int gravida;

  @HiveField(12)
  int parity;

  @HiveField(13)
  bool previousPregnancies;

  @HiveField(14)
  bool familyIllness;

  @HiveField(15)
  String? familyIllnessDetails;

  @HiveField(16)
  String? medicalHistory;

  @HiveField(17)
  List<String>? testFileNames;

  @HiveField(18)
  List<String>? testFilePaths;

  @HiveField(19)
  String patientId;

  @HiveField(20)
  DateTime? dateOfBirth;

  @HiveField(21)
  bool pendingSync;

  PregnancyRecord({
    required this.id,
    required this.midwifeName,
    required this.motherName,
    required this.lastMenstrualPeriod,
    required this.expectedDeliveryDate,
    required this.age,
    required this.phone,
    required this.address,
    required this.gravida,
    required this.parity,
    required this.previousPregnancies,
    required this.familyIllness,
    this.familyIllnessDetails,
    this.medicalHistory,
    this.testFileNames,
    this.testFilePaths,
    this.notes,
    required this.patientId,
    this.dateOfBirth,
    List<CheckupRecord>? checkups,
    DateTime? createdAt,
    String? testFileUrl,
    this.pendingSync = false,
  }) : checkups = checkups ?? [],
       createdAt = createdAt ?? DateTime.now();

  PregnancyRecord copyWith({
    String? patientId,
    String? id,
    String? midwifeName,
    String? motherName,
    int? age,
    String? phone,
    String? address,
    int? gravida,
    int? parity,
    bool? previousPregnancies,
    bool? familyIllness,
    String? familyIllnessDetails,
    String? medicalHistory,
    List<String>? testFileNames,
    List<String>? testFilePaths,
    DateTime? lastMenstrualPeriod,
    DateTime? expectedDeliveryDate,
    String? notes,
    List<CheckupRecord>? checkups,
    DateTime? createdAt,
    DateTime? dateOfBirth,
  }) {
    return PregnancyRecord(
      patientId: patientId ?? this.patientId,
      id: id ?? this.id,
      midwifeName: midwifeName ?? this.midwifeName,
      motherName: motherName ?? this.motherName,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gravida: gravida ?? this.gravida,
      parity: parity ?? this.parity,
      previousPregnancies: previousPregnancies ?? this.previousPregnancies,
      familyIllness: familyIllness ?? this.familyIllness,
      familyIllnessDetails: familyIllnessDetails ?? this.familyIllnessDetails,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      testFileNames: testFileNames ?? this.testFileNames,
      testFilePaths: testFilePaths ?? this.testFilePaths,
      lastMenstrualPeriod: lastMenstrualPeriod ?? this.lastMenstrualPeriod,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      notes: notes ?? this.notes,
      checkups: checkups ?? this.checkups,
      createdAt: createdAt ?? this.createdAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'midwifeName': midwifeName,
      'motherName': motherName,
      'lastMenstrualPeriod': lastMenstrualPeriod.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate.toIso8601String(),
      'age': age,
      'phone': phone,
      'address': address,
      'gravida': gravida,
      'parity': parity,
      'previousPregnancies': previousPregnancies,
      'familyIllness': familyIllness,
      'familyIllnessDetails': familyIllnessDetails,
      'medicalHistory': medicalHistory,
      'testFileNames': testFileNames ?? [],
      'testFilePaths': testFilePaths ?? [],
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'checkups': checkups.map((c) => c.toJson()).toList(),
    };
  }

  factory PregnancyRecord.fromJson(Map<String, dynamic> json) {
    return PregnancyRecord(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      midwifeName: json['midwifeName'] ?? '',
      motherName: json['motherName'] ?? '',
      lastMenstrualPeriod: DateTime.parse(json['lastMenstrualPeriod']),
      expectedDeliveryDate: DateTime.parse(json['expectedDeliveryDate']),
      age: json['age'] ?? 0,
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      gravida: json['gravida'] ?? 0,
      parity: json['parity'] ?? 0,
      previousPregnancies: json['previousPregnancies'] ?? false,
      familyIllness: json['familyIllness'] ?? false,
      familyIllnessDetails: json['familyIllnessDetails'],
      medicalHistory: json['medicalHistory'],
      testFileNames: (json['testFileNames'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      testFilePaths: (json['testFilePaths'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      checkups:
          (json['checkups'] as List<dynamic>?)
              ?.map((e) => CheckupRecord.fromJson(e))
              .toList() ??
          [],
    );
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
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'notes': notes,
      'dangerSigns': dangerSigns,
      'weight': weight,
      'bloodPressure': bloodPressure,
      'heartRate': heartRate,
    };
  }

  factory CheckupRecord.fromJson(Map<String, dynamic> json) {
    return CheckupRecord(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']),
      notes: json['notes'] ?? '',
      dangerSigns: List<String>.from(json['dangerSigns'] ?? []),
      weight: (json['weight'] as num?)?.toDouble(),
      bloodPressure: json['bloodPressure'],
      heartRate: json['heartRate'],
    );
  }
}

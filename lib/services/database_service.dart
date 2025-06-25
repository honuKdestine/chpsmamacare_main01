// import 'package:chpsmamacare_main/models/pregnancy_record.dart';
import 'package:chpsmamacare_main01/models/pregnancy_record.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  final Box<PregnancyRecord> _pregnancyBox = Hive.box<PregnancyRecord>(
    'pregnancy_records',
  );
  final _uuid = const Uuid();

  // Get all pregnancy records
  List<PregnancyRecord> getAllPregnancyRecords() {
    final records = _pregnancyBox.values.toList();
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  // Get a specific pregnancy record
  PregnancyRecord? getPregnancyRecord(String id) {
    try {
      return _pregnancyBox.values.firstWhere((record) => record.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add a new pregnancy recors
  Future<String> addPregnancyRecord(
    String midwifeName,
    String motherName,
    DateTime lastMenstrualPeriod,
    DateTime expectedDeliveryDate,
    String? notes,
  ) async {
    final id = _uuid.v4();
    final record = PregnancyRecord(
      id: id,
      motherName: motherName,
      lastMenstrualPeriod: lastMenstrualPeriod,
      expectedDeliveryDate: expectedDeliveryDate,
      midwifeName: midwifeName,
      notes: notes,
    );
    await _pregnancyBox.put(id, record);
    print("✅Successfully added pregnancy record for $motherName");
    return id;
  }

  // Update a pregnancy record
  Future<void> updatePregnancyRecord(PregnancyRecord record) async {
    await _pregnancyBox.put(record.id, record);
    print("✅Updated pregnancy record for ${record.motherName}");
  }

  // Delete a pregnancy record
  Future<void> deletePregnancyRecord(String id) async {
    await _pregnancyBox.delete(id);
    print("✅ Deleted pregnancy record.");
  }

  // Add a checkup to a pregnancy record
  Future<void> addCheckup(
    String pregnancyId,
    String notes,
    List<String> dangerSigns, {
    double? weight,
    String? bloodPressure,
    int? heartRate,
  }) async {
    final record = getPregnancyRecord(pregnancyId);
    if (record != null) {
      final checkup = CheckupRecord(
        id: _uuid.v4(),
        date: DateTime.now(),
        notes: notes,
        dangerSigns: dangerSigns,
        weight: weight,
        bloodPressure: bloodPressure,
        heartRate: heartRate,
      );

      record.checkups.add(checkup);
      await updatePregnancyRecord(record);
      print("✅ Added checkup for ${record.motherName}");
    }
  }

  // Get records with danger signs
  List<PregnancyRecord> getRecordsWithDangerSigns() {
    return _pregnancyBox.values.where((record) {
      return record.checkups.any((checkup) => checkup.hasDangerSigns);
    }).toList();
  }

  // Get statistics
  Map<String, int> getStatistics() {
    final records = getAllPregnancyRecords();
    final totalRecords = records.length;
    final recordsWithDangerSigns = getRecordsWithDangerSigns().length;
    final totalCheckups = records.fold<int>(
      0,
      (sum, record) => sum + record.checkups.length,
    );

    return {
      'totalRecords': totalRecords,
      'dangerSignRecords': recordsWithDangerSigns,
      'totalCheckups': totalCheckups,
    };
  }
}

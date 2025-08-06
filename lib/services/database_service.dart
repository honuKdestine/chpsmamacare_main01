// import 'package:chpsmamacare_main/models/pregnancy_record.dart';
import 'package:chpsmamacare_main01/models/appointment.dart';
import 'package:chpsmamacare_main01/models/pregnancy_record.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  final _uuid = const Uuid();

  Future<Box<Appointment>> get _appointmentBox async {
    if (!Hive.isBoxOpen('appointments')) {
      await Hive.openBox<Appointment>('appointments');
    }
    return Hive.box<Appointment>('appointments');
  }

  Future<Box<PregnancyRecord>> get _pregnancyBox async {
    if (!Hive.isBoxOpen('pregnancy_records')) {
      await Hive.openBox<PregnancyRecord>('pregnancy_records');
    }
    return Hive.box<PregnancyRecord>('pregnancy_records');
  }

  // Add appointment
  Future<void> addAppointment(Appointment appointment) async {
    final box = await _appointmentBox;
    await box.put(appointment.id, appointment);
    print("Scheduled appointment for ${appointment.motherRecordId}");
  }

  // Get all appointments
  Future<List<Appointment>> getAllAppointments() async {
    final box = await _appointmentBox;
    final records = box.values.toList();
    return records;
  }

  // Get all pregnancy records
  Future<List<PregnancyRecord>> getAllPregnancyRecords() async {
    final box = await _pregnancyBox;
    final records = box.values.toList();
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  // Get a specific pregnancy record
  Future<PregnancyRecord?> getPregnancyRecord(String id) async {
    final box = await _pregnancyBox;
    try {
      return box.values.firstWhere((record) => record.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add a new pregnancy record
  Future<String> addPregnancyRecord({
    required String midwifeName,
    required String motherName,
    required int age,
    required String phone,
    required String address,
    required int gravida,
    required int parity,
    required bool previousPregnancies,
    required bool familyIllness,
    String? familyIllnessDetails,
    String? medicalHistory,
    String? testFileName,
    String? testFilePath,
    required DateTime lastMenstrualPeriod,
    required DateTime expectedDeliveryDate,

    String? notes,
  }) async {
    final id = _uuid.v4();
    final record = PregnancyRecord(
      id: id,
      midwifeName: midwifeName,
      motherName: motherName,
      age: age,
      phone: phone,
      address: address,
      gravida: gravida,
      parity: parity,
      previousPregnancies: previousPregnancies,
      familyIllness: familyIllness,
      familyIllnessDetails: familyIllnessDetails,
      medicalHistory: medicalHistory,
      testFileName: testFileName,
      testFilePath: testFilePath,
      lastMenstrualPeriod: lastMenstrualPeriod,
      expectedDeliveryDate: expectedDeliveryDate,

      notes: notes,
    );
    final box = await _pregnancyBox;
    await box.put(id, record);
    print("Successfully added pregnancy record for $motherName");
    return id;
  }

  // Overloaded method that accepts a PregnancyRecord object
  Future<String> savePregnancyRecord(PregnancyRecord record) async {
    final box = await _pregnancyBox;
    await box.put(record.id, record);
    print("Successfully added pregnancy record for ${record.motherName}");
    return record.id;
  }

  // Update a pregnancy record
  Future<void> updatePregnancyRecord(PregnancyRecord record) async {
    final box = await _pregnancyBox;
    await box.put(record.id, record);
    print("Updated pregnancy record for ${record.motherName}");
  }

  // Delete a pregnancy record
  Future<void> deletePregnancyRecord(String id) async {
    final box = await _pregnancyBox;
    await box.delete(id);
    print("Deleted pregnancy record.");
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
    final record = await getPregnancyRecord(pregnancyId);
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
      print("Added checkup for ${record.motherName}");
    }
  }

  // Get records with danger signs
  Future<List<PregnancyRecord>> getRecordsWithDangerSigns() async {
    final box = await _pregnancyBox;
    return box.values.where((record) {
      return record.checkups.any((checkup) => checkup.hasDangerSigns);
    }).toList();
  }

  // Update Appointment Status
  Future<void> updateAppointmentStatus(String id, String newStatus) async {
    final box = Hive.box<Appointment>('appointments');
    final appointment = box.get(id);
    if (appointment != null) {
      appointment.status = newStatus;
      await appointment.save();
    }
  }

  // Delete APpointment
  Future<void> deleteAppointment(String id) async {
    final box = Hive.box<Appointment>('appointments');
    await box.delete(id);
  }

  // Get statistics
  Future<Map<String, int>> getStatistics() async {
    final records = await getAllPregnancyRecords();
    final totalAppointmentRecords = await getAllAppointments();
    final totalRecords = records.length;
    final dangerRecords = await getRecordsWithDangerSigns();
    final recordsWithDangerSigns = dangerRecords.length;
    final totalCheckups = records.fold<int>(
      0,
      (sum, record) => sum + record.checkups.length,
    );

    return {
      'totalRecords': totalRecords,
      'dangerSignRecords': recordsWithDangerSigns,
      'totalCheckups': totalCheckups,
      'totalAppointments': totalAppointmentRecords.length,
    };
  }
}

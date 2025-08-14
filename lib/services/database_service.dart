// // import 'package:chpsmamacare_main/models/pregnancy_record.dart';
// import 'dart:io';

// import 'package:chpsmamacare_main01/models/appointment.dart';
// import 'package:chpsmamacare_main01/models/pregnancy_record.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:chpsmamacare_main01/utils/network_utils.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:hive/hive.dart';
// import 'package:uuid/uuid.dart';

// class DatabaseService {
//   final _uuid = const Uuid();
//   final patientId = DateTime.now().millisecondsSinceEpoch
//       .toString(); // e.g. "209658249"

//   Future<Box<Appointment>> get _appointmentBox async {
//     if (!Hive.isBoxOpen('appointments')) {
//       await Hive.openBox<Appointment>('appointments');
//     }
//     return Hive.box<Appointment>('appointments');
//   }

//   Future<Box<PregnancyRecord>> get _pregnancyBox async {
//     if (!Hive.isBoxOpen('pregnancy_records')) {
//       await Hive.openBox<PregnancyRecord>('pregnancy_records');
//     }
//     return Hive.box<PregnancyRecord>('pregnancy_records');
//   }

//   // Add appointment
//   Future<void> addAppointment(Appointment appointment) async {
//     final box = await _appointmentBox;
//     await box.put(appointment.id, appointment);
//     print("Scheduled appointment for ${appointment.motherRecordId}");
//   }

//   // Get all appointments
//   Future<List<Appointment>> getAllAppointments() async {
//     final box = await _appointmentBox;
//     final records = box.values.toList();
//     return records;
//   }

//   // Get all pregnancy records
//   Future<List<PregnancyRecord>> getAllPregnancyRecords() async {
//     final box = await _pregnancyBox;

//     if (await isOnline()) {
//       try {
//         final snapshot = await FirebaseFirestore.instance
//             .collection('pregnancy_records')
//             .get();

//         List<PregnancyRecord> firestoreRecords = snapshot.docs.map((doc) {
//           final data = doc.data();
//           return PregnancyRecord.fromJson(data);
//         }).toList();

//         // Sort by most recent
//         firestoreRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));

//         // Cache to Hive for offline access
//         for (var record in firestoreRecords) {
//           await box.put(record.id, record);
//         }

//         print("✅ Loaded records from Firestore (${firestoreRecords.length})");
//         return firestoreRecords;
//       } catch (e) {
//         print("⚠️ Failed to load from Firestore, falling back to Hive: $e");
//       }
//     }

//     // Fallback: load from Hive
//     final localRecords = box.values.toList();
//     localRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//     print("📴 Loaded records from local Hive (${localRecords.length})");
//     return localRecords;
//   }

//   // Get a specific pregnancy record
//   Future<PregnancyRecord?> getPregnancyRecord(String id) async {
//     final box = await _pregnancyBox;
//     try {
//       return box.values.firstWhere((record) => record.id == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<Map<String, dynamic>> generateNextPatientDetails() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('pregnancy_records')
//         .orderBy('patientNumber', descending: true)
//         .limit(1)
//         .get();

//     if (snapshot.docs.isEmpty) {
//       return {'patientId': 'P-0001', 'patientNumber': 1};
//     }

//     final lastNumber = snapshot.docs.first['patientNumber'] ?? 0;
//     final nextNumber = lastNumber + 1;

//     return {
//       'patientId': 'P-${nextNumber.toString().padLeft(4, '0')}',
//       'patientNumber': nextNumber,
//     };
//   }

//   // Add a new pregnancy record
//   Future<String> addPregnancyRecord({
//     required String midwifeName,
//     required String motherName,
//     required int age,
//     required String phone,
//     required String address,
//     required int gravida,
//     required int parity,
//     required bool previousPregnancies,
//     required bool familyIllness,
//     String? familyIllnessDetails,
//     String? medicalHistory,
//     List<String>? testFileNames,
//     List<String>? testFilePaths,
//     required DateTime lastMenstrualPeriod,
//     required DateTime expectedDeliveryDate,
//     String? notes,
//   }) async {
//     final id = _uuid.v4();

//     //  Generate next patientId & number
//     final patientDetails = await generateNextPatientDetails();
//     final patientId = patientDetails['patientId'];
//     final patientNumber = patientDetails['patientNumber'];

//     List<String> uploadedFileUrls = [];
//     if (testFilePaths != null && testFileNames != null) {
//       for (int i = 0; i < testFilePaths.length; i++) {
//         final path = testFilePaths[i];
//         final name = testFileNames[i];
//         if (File(path).existsSync()) {
//           try {
//             final storageRef = FirebaseStorage.instance.ref().child(
//               'test_files/$id/$name',
//             );
//             await storageRef.putFile(File(path));
//             final downloadUrl = await storageRef.getDownloadURL();
//             uploadedFileUrls.add(downloadUrl);
//             print("☁️ Uploaded $name to Firebase Storage");
//           } catch (e) {
//             print("⚠️ File upload failed for $name: $e");
//           }
//         }
//       }
//     }

//     final record = PregnancyRecord(
//       id: id,
//       patientId: patientId,
//       midwifeName: midwifeName,
//       motherName: motherName,
//       age: age,
//       phone: phone,
//       address: address,
//       gravida: gravida,
//       parity: parity,
//       previousPregnancies: previousPregnancies,
//       familyIllness: familyIllness,
//       familyIllnessDetails: familyIllnessDetails,
//       medicalHistory: medicalHistory,
//       testFileNames: testFileNames ?? [],
//       testFilePaths: uploadedFileUrls,
//       lastMenstrualPeriod: lastMenstrualPeriod,
//       expectedDeliveryDate: expectedDeliveryDate,
//       notes: notes,
//     );

//     final box = await _pregnancyBox;
//     await box.put(id, record);

//     try {
//       await FirebaseFirestore.instance
//           .collection('pregnancy_records')
//           .doc(record.id)
//           .set({
//             ...record.toJson(),
//             'patientNumber': patientNumber, // 🔹 extra numeric field
//           })
//           .timeout(const Duration(seconds: 5));
//       print("☁️ Firestore write finished within timeout");
//     } catch (e) {
//       print("⚠️ Firestore write timed out or failed: $e");
//     }

//     return record.id;
//   }

//   // Update a pregnancy record
//   Future<void> updatePregnancyRecord(PregnancyRecord record) async {
//     if ((record.testFilePaths ?? []).isNotEmpty) {
//       try {
//         List<String> updatedUrls = [];

//         for (int i = 0; i < record.testFilePaths!.length; i++) {
//           String localPath = record.testFilePaths![i];

//           if (File(localPath).existsSync()) {
//             final storageRef = FirebaseStorage.instance.ref().child(
//               'test_files/${record.id}/${record.testFileNames![i]}',
//             );

//             await storageRef.putFile(File(localPath));
//             final downloadUrl = await storageRef.getDownloadURL();
//             updatedUrls.add(downloadUrl);

//             print(
//               "☁️ Uploaded ${record.testFileNames![i]} to Firebase Storage",
//             );
//           } else {
//             updatedUrls.add(localPath); // Keep old URL if it's already uploaded
//           }
//         }

//         // Update record with Firebase URLs
//         record.testFilePaths = updatedUrls;
//       } catch (e) {
//         print("⚠️ File update failed: $e");
//       }
//     }

//     // Save locally
//     final box = await _pregnancyBox;
//     await box.put(record.id, record);
//     print("Updated pregnancy record locally for ${record.motherName}");

//     // Sync with Firestore
//     FirebaseFirestore.instance
//         .collection('pregnancy_records')
//         .doc(record.id)
//         .set(record.toJson(), SetOptions(merge: true))
//         .then((_) {
//           print("☁️ Synced updated record to Firestore");
//         })
//         .catchError((e, st) {
//           print("⚠️ Firestore sync failed on update: $e");
//           print(st);
//         });
//   }

//   // Delete a pregnancy record
//   Future<void> deletePregnancyRecord(String id) async {
//     final box = await _pregnancyBox;
//     await box.delete(id);
//     print("Deleted pregnancy record.");
//   }

//   // Add a checkup to a pregnancy record
//   Future<void> addCheckup(
//     String pregnancyId,
//     String notes,
//     List<String> dangerSigns, {
//     double? weight,
//     String? bloodPressure,
//     int? heartRate,
//   }) async {
//     final record = await getPregnancyRecord(pregnancyId);
//     if (record != null) {
//       final checkup = CheckupRecord(
//         id: _uuid.v4(),
//         date: DateTime.now(),
//         notes: notes,
//         dangerSigns: dangerSigns,
//         weight: weight,
//         bloodPressure: bloodPressure,
//         heartRate: heartRate,
//       );

//       record.checkups.add(checkup);
//       await updatePregnancyRecord(record);
//       print("Added checkup for ${record.motherName}");
//     }
//   }

//   // Get records with danger signs
//   Future<List<PregnancyRecord>> getRecordsWithDangerSigns() async {
//     final box = await _pregnancyBox;
//     return box.values.where((record) {
//       return record.checkups.any((checkup) => checkup.hasDangerSigns);
//     }).toList();
//   }

//   // Update Appointment Status
//   Future<void> updateAppointmentStatus(String id, String newStatus) async {
//     final box = Hive.box<Appointment>('appointments');
//     final appointment = box.get(id);
//     if (appointment != null) {
//       appointment.status = newStatus;
//       await appointment.save();
//     }
//   }

//   // Delete Appointment
//   Future<void> deleteAppointment(String id) async {
//     final box = Hive.box<Appointment>('appointments');
//     await box.delete(id);
//   }

//   // Get statistics
//   Future<Map<String, int>> getStatistics() async {
//     final records = await getAllPregnancyRecords();
//     final totalAppointmentRecords = await getAllAppointments();
//     final totalRecords = records.length;
//     final dangerRecords = await getRecordsWithDangerSigns();
//     final recordsWithDangerSigns = dangerRecords.length;
//     final totalCheckups = records.fold<int>(
//       0,
//       (sum, record) => sum + record.checkups.length,
//     );

//     return {
//       'totalRecords': totalRecords,
//       'dangerSignRecords': recordsWithDangerSigns,
//       'totalCheckups': totalCheckups,
//       'totalAppointments': totalAppointmentRecords.length,
//     };
//   }
// }

// import 'package:chpsmamacare_main/models/pregnancy_record.dart';
// import 'dart:io';

// import 'package:chpsmamacare_main01/models/appointment.dart';
// import 'package:chpsmamacare_main01/models/pregnancy_record.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:chpsmamacare_main01/utils/network_utils.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:hive/hive.dart';
// import 'package:uuid/uuid.dart';

// class DatabaseService {
//   final _uuid = const Uuid();
//   final patientId = DateTime.now().millisecondsSinceEpoch
//       .toString(); // e.g. "209658249"

//   Future<Box<Appointment>> get _appointmentBox async {
//     if (!Hive.isBoxOpen('appointments')) {
//       await Hive.openBox<Appointment>('appointments');
//     }
//     return Hive.box<Appointment>('appointments');
//   }

//   Future<Box<PregnancyRecord>> get _pregnancyBox async {
//     if (!Hive.isBoxOpen('pregnancy_records')) {
//       await Hive.openBox<PregnancyRecord>('pregnancy_records');
//     }
//     return Hive.box<PregnancyRecord>('pregnancy_records');
//   }

//   // Add appointment
//   Future<void> addAppointment(Appointment appointment) async {
//     final box = await _appointmentBox;
//     await box.put(appointment.id, appointment);
//     print("Scheduled appointment for ${appointment.motherRecordId}");
//   }

//   // Get all appointments
//   Future<List<Appointment>> getAllAppointments() async {
//     final box = await _appointmentBox;
//     final records = box.values.toList();
//     return records;
//   }

//   // Get all pregnancy records
//   Future<List<PregnancyRecord>> getAllPregnancyRecords() async {
//     final box = await _pregnancyBox;

//     if (await isOnline()) {
//       try {
//         final snapshot = await FirebaseFirestore.instance
//             .collection('pregnancy_records')
//             .get();

//         List<PregnancyRecord> firestoreRecords = snapshot.docs.map((doc) {
//           final data = doc.data();
//           return PregnancyRecord.fromJson(data);
//         }).toList();

//         // Sort by most recent
//         firestoreRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));

//         // Cache to Hive for offline access
//         for (var record in firestoreRecords) {
//           await box.put(record.id, record);
//         }

//         print("✅ Loaded records from Firestore (${firestoreRecords.length})");
//         return firestoreRecords;
//       } catch (e) {
//         print("⚠️ Failed to load from Firestore, falling back to Hive: $e");
//       }
//     }

//     // Fallback: load from Hive
//     final localRecords = box.values.toList();
//     localRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//     print("📴 Loaded records from local Hive (${localRecords.length})");
//     return localRecords;
//   }

//   // Get a specific pregnancy record
//   Future<PregnancyRecord?> getPregnancyRecord(String id) async {
//     final box = await _pregnancyBox;
//     try {
//       return box.values.firstWhere((record) => record.id == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<Map<String, dynamic>> generateNextPatientDetails() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('pregnancy_records')
//         .orderBy('patientNumber', descending: true)
//         .limit(1)
//         .get();

//     if (snapshot.docs.isEmpty) {
//       return {'patientId': 'P-0001', 'patientNumber': 1};
//     }

//     final lastNumber = snapshot.docs.first['patientNumber'] ?? 0;
//     final nextNumber = lastNumber + 1;

//     return {
//       'patientId': 'P-${nextNumber.toString().padLeft(4, '0')}',
//       'patientNumber': nextNumber,
//     };
//   }

//   // Add a new pregnancy record
//   Future<String> addPregnancyRecord({
//     required String midwifeName,
//     required String motherName,
//     required int age,
//     required String phone,
//     required String address,
//     required int gravida,
//     required int parity,
//     required bool previousPregnancies,
//     required bool familyIllness,
//     String? familyIllnessDetails,
//     String? medicalHistory,
//     List<String>? testFileNames,
//     List<String>? testFilePaths,
//     required DateTime lastMenstrualPeriod,
//     required DateTime expectedDeliveryDate,
//     String? notes,
//     DateTime? dateOfBirth, required String patientId,
//   }) async {
//     final id = _uuid.v4();

//     //  Generate next patientId & number
//     final patientDetails = await generateNextPatientDetails();
//     final patientId = patientDetails['patientId'];
//     final patientNumber = patientDetails['patientNumber'];

//     final record = PregnancyRecord(
//       id: id,
//       patientId: patientId,
//       midwifeName: midwifeName,
//       motherName: motherName,
//       age: age,
//       phone: phone,
//       address: address,
//       gravida: gravida,
//       parity: parity,
//       previousPregnancies: previousPregnancies,
//       familyIllness: familyIllness,
//       familyIllnessDetails: familyIllnessDetails,
//       medicalHistory: medicalHistory,
//       testFileNames: testFileNames ?? [],
//       testFilePaths: testFilePaths ?? [],
//       lastMenstrualPeriod: lastMenstrualPeriod,
//       expectedDeliveryDate: expectedDeliveryDate,
//       notes: notes,
//       dateOfBirth: dateOfBirth,
//     );

//     final box = await _pregnancyBox;
//     await box.put(id, record);

//     try {
//       await FirebaseFirestore.instance
//           .collection('pregnancy_records')
//           .doc(record.id)
//           .set({...record.toJson(), 'patientNumber': patientNumber})
//           .timeout(const Duration(seconds: 5));
//       print("☁️ Firestore write finished within timeout");
//     } catch (e) {
//       print("⚠️ Firestore write timed out or failed: $e");
//     }

//     return record.id;
//   }

//   // Update a pregnancy record
//   Future<void> updatePregnancyRecord(PregnancyRecord record) async {
//     if ((record.testFilePaths ?? []).isNotEmpty) {
//       try {
//         List<String> updatedUrls = [];

//         for (int i = 0; i < record.testFilePaths!.length; i++) {
//           String pathOrUrl = record.testFilePaths![i];

//           if (pathOrUrl.startsWith('http')) {
//             updatedUrls.add(pathOrUrl);
//           } else if (File(pathOrUrl).existsSync()) {
//             final storageRef = FirebaseStorage.instance.ref().child(
//               'test_files/${record.id}/${record.testFileNames![i]}',
//             );

//             await storageRef.putFile(File(pathOrUrl));
//             final downloadUrl = await storageRef.getDownloadURL();
//             updatedUrls.add(downloadUrl);

//             print(
//               "☁️ Uploaded ${record.testFileNames![i]} to Firebase Storage",
//             );
//           } else {
//             updatedUrls.add(pathOrUrl);
//           }
//         }

//         record.testFilePaths = updatedUrls;
//       } catch (e) {
//         print("⚠️ File update failed: $e");
//       }
//     }

//     final box = await _pregnancyBox;
//     await box.put(record.id, record);
//     print("Updated pregnancy record locally for ${record.motherName}");

//     FirebaseFirestore.instance
//         .collection('pregnancy_records')
//         .doc(record.id)
//         .set(record.toJson(), SetOptions(merge: true))
//         .then((_) {
//           print("☁️ Synced updated record to Firestore");
//         })
//         .catchError((e, st) {
//           print("⚠️ Firestore sync failed on update: $e");
//           print(st);
//         });
//   }

//   // Delete a pregnancy record
//   Future<void> deletePregnancyRecord(String id) async {
//     final box = await _pregnancyBox;
//     await box.delete(id);
//     print("Deleted pregnancy record.");
//   }

//   // Add a checkup to a pregnancy record
//   Future<void> addCheckup(
//     String pregnancyId,
//     String notes,
//     List<String> dangerSigns, {
//     double? weight,
//     String? bloodPressure,
//     int? heartRate,
//   }) async {
//     final record = await getPregnancyRecord(pregnancyId);
//     if (record != null) {
//       final checkup = CheckupRecord(
//         id: _uuid.v4(),
//         date: DateTime.now(),
//         notes: notes,
//         dangerSigns: dangerSigns,
//         weight: weight,
//         bloodPressure: bloodPressure,
//         heartRate: heartRate,
//       );

//       record.checkups.add(checkup);
//       await updatePregnancyRecord(record);
//       print("Added checkup for ${record.motherName}");
//     }
//   }

//   // Get records with danger signs
//   Future<List<PregnancyRecord>> getRecordsWithDangerSigns() async {
//     final box = await _pregnancyBox;
//     return box.values.where((record) {
//       return record.checkups.any((checkup) => checkup.hasDangerSigns);
//     }).toList();
//   }

//   // Update Appointment Status
//   Future<void> updateAppointmentStatus(String id, String newStatus) async {
//     final box = Hive.box<Appointment>('appointments');
//     final appointment = box.get(id);
//     if (appointment != null) {
//       appointment.status = newStatus;
//       await appointment.save();
//     }
//   }

//   // Delete Appointment
//   Future<void> deleteAppointment(String id) async {
//     final box = Hive.box<Appointment>('appointments');
//     await box.delete(id);
//   }

//   // Get statistics
//   Future<Map<String, int>> getStatistics() async {
//     final records = await getAllPregnancyRecords();
//     final totalAppointmentRecords = await getAllAppointments();
//     final totalRecords = records.length;
//     final dangerRecords = await getRecordsWithDangerSigns();
//     final recordsWithDangerSigns = dangerRecords.length;
//     final totalCheckups = records.fold<int>(
//       0,
//       (sum, record) => sum + record.checkups.length,
//     );

//     return {
//       'totalRecords': totalRecords,
//       'dangerSignRecords': recordsWithDangerSigns,
//       'totalCheckups': totalCheckups,
//       'totalAppointments': totalAppointmentRecords.length,
//     };
//   }
// }


import 'package:chpsmamacare_main01/models/appointment.dart';
import 'package:chpsmamacare_main01/models/pregnancy_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chpsmamacare_main01/utils/network_utils.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  final _uuid = const Uuid();
  final patientId = DateTime.now().millisecondsSinceEpoch
      .toString(); // e.g. "209658249"

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

    if (await isOnline()) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('pregnancy_records')
            .get();

        List<PregnancyRecord> firestoreRecords = snapshot.docs.map((doc) {
          final data = doc.data();
          return PregnancyRecord.fromJson(data);
        }).toList();

        // Sort by most recent
        firestoreRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Cache to Hive for offline access
        for (var record in firestoreRecords) {
          await box.put(record.id, record);
        }

        print("✅ Loaded records from Firestore (${firestoreRecords.length})");
        return firestoreRecords;
      } catch (e) {
        print("⚠️ Failed to load from Firestore, falling back to Hive: $e");
      }
    }

    // Fallback: load from Hive
    final localRecords = box.values.toList();
    localRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    print("📴 Loaded records from local Hive (${localRecords.length})");
    return localRecords;
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

  Future<Map<String, dynamic>> generateNextPatientDetails() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('pregnancy_records')
        .orderBy('patientNumber', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return {'patientId': 'P-0001', 'patientNumber': 1};
    }

    final lastNumber = snapshot.docs.first['patientNumber'] ?? 0;
    final nextNumber = lastNumber + 1;

    return {
      'patientId': 'P-${nextNumber.toString().padLeft(4, '0')}',
      'patientNumber': nextNumber,
    };
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
    List<String>? testFileNames,
    List<String>? testFilePaths,
    required DateTime lastMenstrualPeriod,
    required DateTime expectedDeliveryDate,
    String? notes,
    DateTime? dateOfBirth, required String patientId,
  }) async {
    final id = _uuid.v4();

    //  Generate next patientId & number
    final patientDetails = await generateNextPatientDetails();
    final patientId = patientDetails['patientId'];
    final patientNumber = patientDetails['patientNumber'];

    final record = PregnancyRecord(
      id: id,
      patientId: patientId,
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
      testFileNames: testFileNames ?? [],
      testFilePaths: testFilePaths ?? [],
      lastMenstrualPeriod: lastMenstrualPeriod,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes,
      dateOfBirth: dateOfBirth,
    );

    final box = await _pregnancyBox;
    await box.put(id, record);

    try {
      await FirebaseFirestore.instance
          .collection('pregnancy_records')
          .doc(record.id)
          .set({...record.toJson(), 'patientNumber': patientNumber})
          .timeout(const Duration(seconds: 5));
      print("☁️ Firestore write finished within timeout");
    } catch (e) {
      print("⚠️ Firestore write timed out or failed: $e");
    }

    return record.id;
  }

  // Update a pregnancy record
  Future<void> updatePregnancyRecord(PregnancyRecord record) async {
    // if ((record.testFilePaths ?? []).isNotEmpty) {
    //   try {
    //     List<String> updatedUrls = [];

    //     for (int i = 0; i < record.testFilePaths!.length; i++) {
    //       String pathOrUrl = record.testFilePaths![i];

    //       if (pathOrUrl.startsWith('http')) {
    //         updatedUrls.add(pathOrUrl);
    //       } else if (File(pathOrUrl).existsSync()) {
    //         final storageRef = FirebaseStorage.instance.ref().child(
    //           'test_files/${record.id}/${record.testFileNames![i]}',
    //         );

    //         await storageRef.putFile(File(pathOrUrl));
    //         final downloadUrl = await storageRef.getDownloadURL();
    //         updatedUrls.add(downloadUrl);

    //         print(
    //           "☁️ Uploaded ${record.testFileNames![i]} to Firebase Storage",
    //         );
    //       } else {
    //         updatedUrls.add(pathOrUrl);
    //       }
    //     }

    //     record.testFilePaths = updatedUrls;
    //   } catch (e) {
    //     print("⚠️ File update failed: $e");
    //   }
    // }

    final box = await _pregnancyBox;
    await box.put(record.id, record);
    print("Updated pregnancy record locally for ${record.motherName}");

    FirebaseFirestore.instance
        .collection('pregnancy_records')
        .doc(record.id)
        .set(record.toJson(), SetOptions(merge: true))
        .then((_) {
          print("☁️ Synced updated record to Firestore");
        })
        .catchError((e, st) {
          print("⚠️ Firestore sync failed on update: $e");
          print(st);
        });
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

  // Delete Appointment
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

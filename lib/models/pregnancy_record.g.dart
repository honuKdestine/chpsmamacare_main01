// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pregnancy_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PregnancyRecordAdapter extends TypeAdapter<PregnancyRecord> {
  @override
  final int typeId = 0;

  @override
  PregnancyRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PregnancyRecord(
      id: fields[0] as String,
      midwifeName: fields[7] as String,
      motherName: fields[1] as String,
      lastMenstrualPeriod: fields[2] as DateTime,
      expectedDeliveryDate: fields[3] as DateTime,
      age: fields[8] as int,
      phone: fields[9] as String,
      address: fields[10] as String,
      gravida: fields[11] as int,
      parity: fields[12] as int,
      previousPregnancies: fields[13] as bool,
      familyIllness: fields[14] as bool,
      familyIllnessDetails: fields[15] as String?,
      medicalHistory: fields[16] as String?,
      testFileNames: (fields[17] as List?)?.cast<String>(),
      testFilePaths: (fields[18] as List?)?.cast<String>(),
      notes: fields[4] as String?,
      patientId: fields[19] as String,
      dateOfBirth: fields[20] as DateTime?,
      checkups: (fields[5] as List?)?.cast<CheckupRecord>(),
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PregnancyRecord obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.motherName)
      ..writeByte(2)
      ..write(obj.lastMenstrualPeriod)
      ..writeByte(3)
      ..write(obj.expectedDeliveryDate)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.checkups)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.midwifeName)
      ..writeByte(8)
      ..write(obj.age)
      ..writeByte(9)
      ..write(obj.phone)
      ..writeByte(10)
      ..write(obj.address)
      ..writeByte(11)
      ..write(obj.gravida)
      ..writeByte(12)
      ..write(obj.parity)
      ..writeByte(13)
      ..write(obj.previousPregnancies)
      ..writeByte(14)
      ..write(obj.familyIllness)
      ..writeByte(15)
      ..write(obj.familyIllnessDetails)
      ..writeByte(16)
      ..write(obj.medicalHistory)
      ..writeByte(17)
      ..write(obj.testFileNames)
      ..writeByte(18)
      ..write(obj.testFilePaths)
      ..writeByte(19)
      ..write(obj.patientId)
      ..writeByte(20)
      ..write(obj.dateOfBirth);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PregnancyRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CheckupRecordAdapter extends TypeAdapter<CheckupRecord> {
  @override
  final int typeId = 1;

  @override
  CheckupRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CheckupRecord(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      notes: fields[2] as String,
      dangerSigns: (fields[3] as List?)?.cast<String>(),
      weight: fields[4] as double?,
      bloodPressure: fields[5] as String?,
      heartRate: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CheckupRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.dangerSigns)
      ..writeByte(4)
      ..write(obj.weight)
      ..writeByte(5)
      ..write(obj.bloodPressure)
      ..writeByte(6)
      ..write(obj.heartRate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckupRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

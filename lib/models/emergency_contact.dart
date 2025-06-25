import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'emergency_contact.g.dart';

@HiveType(typeId: 3)
class EmergencyContact extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phoneNumber;

  @HiveField(3)
  final String? role;

  @HiveField(4)
  final bool isPrimary;

  @HiveField(5)
  final DateTime createdAt;

  EmergencyContact({
    String? id,
    required this.name,
    required this.phoneNumber,
    this.role,
    this.isPrimary = false,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();
}

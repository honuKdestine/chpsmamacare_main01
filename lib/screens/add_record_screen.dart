import 'dart:io';
import 'package:chpsmamacare_main01/models/pregnancy_record.dart';
import 'package:chpsmamacare_main01/services/database_service.dart';
import 'package:chpsmamacare_main01/services/storage_service.dart';
import 'package:chpsmamacare_main01/utils/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

class AddRecordScreen extends StatefulWidget {
  final PregnancyRecord? existingRecord;
  final String patientId;

  const AddRecordScreen({
    super.key,
    this.existingRecord,
    required this.patientId,
  });

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController gravidaController;
  late TextEditingController parityController;
  late TextEditingController medicalHistoryController;
  List<String> testFileNames = [];
  List<String> testFilePaths = [];
  final List<File> _selectedFiles = [];
  List<String> uploadedFileUrls = [];

  late TextEditingController familyIllnessController;
  late TextEditingController notesController;
  late TextEditingController midwifeNameController;
  bool previousPregnancies = false;
  final formKey = GlobalKey<FormState>();

  PregnancyRecord? existingRecord;
  late DateTime lmp;
  late DateTime edd;
  late bool familyIllness;
  DateTime? dateOfBirth;

  final DatabaseService _databaseService = DatabaseService();
  final DateFormat _dateFormat = DateFormat('dd MMM, yyyy');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers before use in the widget tree
    nameController = TextEditingController();
    ageController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    gravidaController = TextEditingController();
    parityController = TextEditingController();
    medicalHistoryController = TextEditingController();
    familyIllnessController = TextEditingController();
    notesController = TextEditingController();
    midwifeNameController = TextEditingController();
    familyIllness = false;
    lmp = DateTime.now();
    edd = DateTime.now().add(const Duration(days: 280)); // Default EDD
    previousPregnancies = false;
    testFileNames = <String>[];
    testFilePaths = <String>[];
    _isLoading = false;
    // If editing an existing record, populate the fields

    existingRecord = widget.existingRecord;

    if (existingRecord != null) {
      nameController.text = existingRecord!.motherName;
      ageController.text = existingRecord!.age.toString();
      phoneController.text = existingRecord!.phone;
      addressController.text = existingRecord!.address;
      gravidaController.text = existingRecord!.gravida.toString();
      parityController.text = existingRecord!.parity.toString();
      midwifeNameController.text = existingRecord!.midwifeName;
      medicalHistoryController.text = existingRecord!.medicalHistory ?? '';
      notesController.text = existingRecord!.notes ?? '';
      familyIllness = existingRecord!.familyIllness;
      familyIllnessController.text = existingRecord!.familyIllnessDetails ?? '';
      lmp = existingRecord!.lastMenstrualPeriod;
      edd = existingRecord!.expectedDeliveryDate;
      dateOfBirth = existingRecord!.dateOfBirth;
    }
  }

  // Generate a unique ID for new records
  @override
  void dispose() {
    nameController.dispose();
    notesController.dispose();
    ageController.dispose();
    phoneController.dispose();
    addressController.dispose();
    gravidaController.dispose();
    parityController.dispose();
    medicalHistoryController.dispose();
    familyIllnessController.dispose();
    super.dispose();
  }

  String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _selectDate(BuildContext context, bool isLMP) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isLMP) {
          lmp = picked;
          // Calculate EDD (LMP + 280 days)
          edd = picked.add(const Duration(days: 280));
        } else {
          edd = picked;
        }
      });
    }
  }

  Future<String> generateNextPatientId() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('pregnancyRecords')
        .orderBy('patientNumber', descending: true)
        .limit(1)
        .get();

    int nextNumber = 1;
    if (snapshot.docs.isNotEmpty) {
      nextNumber = (snapshot.docs.first['patientNumber'] ?? 0) + 1;
    }

    return 'P-${nextNumber.toString().padLeft(4, '0')}';
  }

  void _saveRecord() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String patientId = existingRecord == null
        ? await generateNextPatientId()
        : existingRecord!.patientId;

    List<String> finalFilePaths = existingRecord?.testFilePaths != null
        ? List.from(existingRecord!.testFilePaths!)
        : [];
    List<String> finalFileNames = existingRecord?.testFileNames != null
        ? List.from(existingRecord!.testFileNames!)
        : [];

    bool isOnline = await _isOnline();

    try {
      // Try to upload files, but fall back to local paths if it fails
      for (int i = 0; i < testFilePaths.length; i++) {
        final path = testFilePaths[i];
        final name = testFileNames[i];

        if (isOnline) {
          try {
            final url = await StorageService().uploadTestFile(path, name);
            finalFilePaths.add(url);
          } catch (e) {
            print("File upload failed, saving locally: $e");
            finalFilePaths.add(path); // fallback to local path
          }
        } else {
          finalFilePaths.add(path);
        }
        finalFileNames.add(name);
      }

      // Save locally first (Hive or SQLite)
      if (existingRecord != null) {
        await _databaseService.updatePregnancyRecord(
          existingRecord!.copyWith(
            midwifeName: midwifeNameController.text.trim(),
            motherName: nameController.text.trim(),
            age: int.tryParse(ageController.text.trim()) ?? 0,
            phone: phoneController.text.trim(),
            address: addressController.text.trim(),
            gravida: int.tryParse(gravidaController.text.trim()) ?? 0,
            parity: int.tryParse(parityController.text.trim()) ?? 0,
            previousPregnancies: previousPregnancies,
            familyIllness: familyIllness,
            familyIllnessDetails: familyIllness
                ? familyIllnessController.text.trim()
                : null,
            medicalHistory: medicalHistoryController.text.trim().isEmpty
                ? null
                : medicalHistoryController.text.trim(),
            testFileNames: finalFileNames,
            testFilePaths: finalFilePaths,
            lastMenstrualPeriod: lmp,
            expectedDeliveryDate: edd,
            notes: notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim(),
            dateOfBirth: dateOfBirth,
          ),
        );
      } else {
        await _databaseService.addPregnancyRecord(
          midwifeName: midwifeNameController.text.trim(),
          motherName: nameController.text.trim(),
          age: int.tryParse(ageController.text.trim()) ?? 0,
          phone: phoneController.text.trim(),
          address: addressController.text.trim(),
          gravida: int.tryParse(gravidaController.text.trim()) ?? 0,
          parity: int.tryParse(parityController.text.trim()) ?? 0,
          previousPregnancies: previousPregnancies,
          familyIllness: familyIllness,
          familyIllnessDetails: familyIllness
              ? familyIllnessController.text.trim()
              : null,
          medicalHistory: medicalHistoryController.text.trim().isEmpty
              ? null
              : medicalHistoryController.text.trim(),
          testFileNames: finalFileNames,
          testFilePaths: finalFilePaths,
          lastMenstrualPeriod: lmp,
          expectedDeliveryDate: edd,
          notes: notesController.text.trim().isEmpty
              ? null
              : notesController.text.trim(),
          dateOfBirth: dateOfBirth,
          patientId: widget.patientId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isOnline
                  ? (existingRecord != null
                        ? 'Record updated successfully'
                        : 'Pregnancy record saved successfully')
                  : 'Saved locally (offline mode)',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Always navigate away
      }
    } catch (e) {
      print("Save record error: $e");

      // Still navigate even if an error occurs
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved locally due to network issue'),
            backgroundColor: AppColors.warning,
          ),
        );
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Widget build(BuildContext context) {
    final sharpBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[400]!, width: 1.2),
    );
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Add Pregnancy Record',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          elevation: 8,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.18),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.18),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Note about required fields
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '* Indicates Required Fields',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.pregnant_woman,
                            color: AppColors.primary,
                            size: 38,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add New Pregnancy Record',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Fill in the details below to add a new pregnancy record',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 78, 77, 77),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Full Name
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Mother\'s Full Name *',
                        prefixIcon: const Icon(Icons.person),
                        hintText: 'Enter the mother\'s full name',
                        border: sharpBorder,
                        enabledBorder: sharpBorder,
                        focusedBorder: sharpBorder,
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter mother\'s name';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Age and Phone
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Age *',
                              border: sharpBorder,
                              enabledBorder: sharpBorder,
                              focusedBorder: sharpBorder,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter age';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone *',
                              border: sharpBorder,
                              enabledBorder: sharpBorder,
                              focusedBorder: sharpBorder,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter phone';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // LMP
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Last Menstrual Period (LMP) *',
                          border: sharpBorder,
                          enabledBorder: sharpBorder,
                          focusedBorder: sharpBorder,
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          lmp == null
                              ? 'Tap to select LMP date'
                              : _dateFormat.format(lmp),
                          style: TextStyle(
                            color: lmp == null ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // EDD
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Expected Delivery Date (EDD) *',
                          border: sharpBorder,
                          enabledBorder: sharpBorder,
                          focusedBorder: sharpBorder,
                          prefixIcon: const Icon(Icons.event),
                        ),
                        child: Text(
                          edd == null
                              ? 'Tap to select EDD (auto-calculated from LMP)'
                              : _dateFormat.format(edd),
                          style: TextStyle(
                            color: edd == null ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Date of Birth
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate:
                              dateOfBirth ??
                              DateTime.now().subtract(
                                const Duration(days: 365 * 25),
                              ),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            dateOfBirth = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateOfBirth != null
                                  ? 'Date of Birth: ${_dateFormat.format(dateOfBirth!)}'
                                  : 'Select Date of Birth',
                              style: TextStyle(
                                fontSize: 16,
                                color: dateOfBirth != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Address
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Address *',
                        border: sharpBorder,
                        enabledBorder: sharpBorder,
                        focusedBorder: sharpBorder,
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 16),

                    // Gravida and Parity
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: gravidaController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Gravida *',
                              border: sharpBorder,
                              enabledBorder: sharpBorder,
                              focusedBorder: sharpBorder,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: parityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Parity *',
                              border: sharpBorder,
                              enabledBorder: sharpBorder,
                              focusedBorder: sharpBorder,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Previous pregnancies (Yes/No checkboxes, overflow safe)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text('Any previous pregnancies? *'),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: previousPregnancies == true,
                                onChanged: (val) {
                                  setState(() {
                                    previousPregnancies = true;
                                  });
                                },
                              ),
                              const Text('Yes'),
                              Checkbox(
                                value: previousPregnancies == false,
                                onChanged: (val) {
                                  setState(() {
                                    previousPregnancies = false;
                                  });
                                },
                              ),
                              const Text('No'),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Illness in family (Yes/No checkboxes, overflow safe)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text('Any illness in the family? *'),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: familyIllness == true,
                                onChanged: (val) {
                                  setState(() {
                                    familyIllness = true;
                                  });
                                },
                              ),
                              const Text('Yes'),
                              Checkbox(
                                value: familyIllness == false,
                                onChanged: (val) {
                                  setState(() {
                                    familyIllness = false;
                                  });
                                },
                              ),
                              const Text('No'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (familyIllness)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextFormField(
                          controller: familyIllnessController,
                          decoration: InputDecoration(
                            labelText: 'Please specify illness *',
                            border: sharpBorder,
                            enabledBorder: sharpBorder,
                            focusedBorder: sharpBorder,
                          ),
                          maxLines: 2,
                        ),
                      ),

                    const SizedBox(height: 16),

                    // File upload for tests (real file picker)
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Test Results'),
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: [
                                    'pdf',
                                    'jpg',
                                    'jpeg',
                                    'png',
                                    'gif',
                                  ],
                                  allowMultiple: true,
                                );
                            if (result != null && result.files.isNotEmpty) {
                              for (var file in result.files) {
                                if (file.path != null) {
                                  setState(() {
                                    testFileNames.add(file.name);
                                    testFilePaths.add(file.path!);
                                  });
                                  print("📁 Selected ${file.name} for upload");
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: testFileNames.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: testFileNames
                                      .map(
                                        (name) => Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                      .toList(),
                                )
                              : const Text(
                                  'No files selected',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    // If a file is selected, show an icon to view it
                    if (testFilePaths.isNotEmpty)
                      Column(
                        children: List.generate(testFilePaths.length, (index) {
                          return ListTile(
                            leading: IconButton(
                              icon: const Icon(Icons.visibility),
                              tooltip: 'View File',
                              onPressed: () async {
                                final path = testFilePaths[index];
                                if (path.startsWith('http')) {
                                  // Use url_launcher for network files
                                  await launchUrl(
                                    Uri.parse(path),
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  final file = File(path);
                                  if (file.existsSync()) {
                                    await OpenFile.open(file.path);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('File not found'),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            title: Text(testFileNames[index]),
                          );
                        }),
                      ),

                    const SizedBox(height: 16),

                    // Medical History
                    TextFormField(
                      controller: medicalHistoryController,
                      decoration: InputDecoration(
                        labelText: 'Medical History (Optional)',
                        hintText: 'Any relevant medical history...',
                        border: sharpBorder,
                        enabledBorder: sharpBorder,
                        focusedBorder: sharpBorder,
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 16),

                    // Additional Notes
                    TextFormField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: 'Additional Notes (Optional)',
                        prefixIcon: const Icon(Icons.note),
                        hintText:
                            'Any additional information about the pregnancy...',
                        border: sharpBorder,
                        enabledBorder: sharpBorder,
                        focusedBorder: sharpBorder,
                      ),
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 16),

                    // Midwife/Health Personnel Name (moved to bottom)
                    TextFormField(
                      controller: midwifeNameController,
                      decoration: InputDecoration(
                        labelText: 'Midwife/Health Personnel Name *',
                        border: sharpBorder,
                        enabledBorder: sharpBorder,
                        focusedBorder: sharpBorder,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the your name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Save and Cancel Buttons (overflow safe)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 500) {
                          // Stack vertically on small screens
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton(
                                onPressed: _isLoading ? null : _saveRecord,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.save),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              existingRecord != null
                                                  ? 'Update Pregnancy Record'
                                                  : 'Add Pregnancy Record',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        Navigator.of(context).pop();
                                      },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: AppColors.primary),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cancel, color: Colors.redAccent),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.redAccent,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Row for larger screens
                          return Row(
                            children: [
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _saveRecord,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.save),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                existingRecord != null
                                                    ? 'Update Pregnancy Record'
                                                    : 'Add Pregnancy Record',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: OutlinedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          Navigator.of(context).pop();
                                        },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: AppColors.primary),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cancel,
                                        color: Colors.redAccent,
                                      ),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.redAccent,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

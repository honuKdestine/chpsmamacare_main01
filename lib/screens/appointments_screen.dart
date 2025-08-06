import 'package:chpsmamacare_main01/models/appointment.dart';
import 'package:chpsmamacare_main01/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final List<Appointment> _appointments = [];
  final DatabaseService _databaseService =
      DatabaseService(); // for patient records
  String? _selectedPatient;
  String? _selectedMotherRecordId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedPurpose;
  final TextEditingController _notesController = TextEditingController();

  //
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  String? _recordedFilePath;
  List<String> _patientNames = [];
  final _audioRecorder = Record();

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _loadAppointments();
  }

  // Load saved appointments on startup
  Future<void> _loadAppointments() async {
    final savedAppointments = await _databaseService.getAllAppointments();
    setState(() {
      _appointments.clear();
      _appointments.addAll(savedAppointments);
    });
  }

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
    return filePath;
  }

  // Toggle recording state
  Future<void> _toggleRecording() async {
    final isRecording = await _audioRecorder.isRecording();

    if (isRecording) {
      final path = await _audioRecorder.stop();
      setState(() {
        _recordedFilePath = path;
        _isRecording = false;
      });
    } else {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required')),
        );
        return;
      }

      final path = await _getFilePath();
      // Stop audio before recording again
      if (_audioPlayer.playing) {
        await _audioPlayer.stop();
      }
      await _audioRecorder.start(path: path, encoder: AudioEncoder.aacLc);

      setState(() {
        _isRecording = true;
      });
    }
  }

  // play recorded audio
  Future<void> _playAudio(String path) async {
    try {
      await _audioPlayer.setFilePath(path);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to play audio')));
    }
  }

  Future<void> _loadPatients() async {
    final records = await _databaseService.getAllPregnancyRecords();
    setState(() {
      _patientNames = records.map((record) => record.motherName).toList();
    });
  }

  void _openAppointmentForm() {
    _selectedPatient = null;
    _selectedDate = null;
    _selectedTime = null;
    _selectedPurpose = null;
    _notesController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Schedule Appointment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Patient Dropdown
              DropdownButtonFormField<String>(
                value: _selectedPatient,
                hint: const Text("Select a patient"),
                items: _patientNames.map((name) {
                  return DropdownMenuItem(value: name, child: Text(name));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedPatient = value);
                },
                decoration: const InputDecoration(labelText: "Patient"),
              ),

              const SizedBox(height: 16),

              // Date & Time Picker
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date'),
                        child: Text(
                          _selectedDate != null
                              ? DateFormat.yMd().format(_selectedDate!)
                              : 'Select Date',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() => _selectedTime = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Time'),
                        child: Text(
                          _selectedTime != null
                              ? _selectedTime!.format(context)
                              : 'Select Time',
                        ),
                      ),
                    ),
                  ),

                  if (_isRecording)
                    const Padding(
                      padding: EdgeInsets.only(left: 50),
                      child: Text(
                        'Recording...',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _toggleRecording,
                        icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                        label: Text(_isRecording ? 'Stop' : 'Record Note'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRecording
                              ? Colors.red
                              : Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (_recordedFilePath != null)
                        ElevatedButton.icon(
                          onPressed: () => _playAudio(_recordedFilePath!),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text("Play"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Purpose Dropdown
              DropdownButtonFormField<String>(
                value: _selectedPurpose,
                hint: const Text("Select Purpose"),
                items:
                    [
                      'Routine Checkup',
                      'Follow Up',
                      'Vaccination',
                      'Ultrasound',
                      'Blood Test',
                      'Emergency',
                      'Others',
                    ].map((purpose) {
                      return DropdownMenuItem(
                        value: purpose,
                        child: Text(purpose),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() => _selectedPurpose = value);
                },
                decoration: const InputDecoration(labelText: "Purpose"),
              ),

              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _scheduleAppointment,
                    child: const Text('Schedule'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _scheduleAppointment() {
    if (_selectedPatient == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedPurpose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final appointment = Appointment(
      id: const Uuid().v4(),
      patientName: _selectedPatient!,
      dateTime: dateTime,
      purpose: _selectedPurpose!,
      notes: _notesController.text,
      soundFile: _recordedFilePath,
      title: _selectedPurpose!,
      motherRecordId: _selectedMotherRecordId,
      status: "pending",
    );

    DatabaseService().addAppointment(appointment).then((_) {
      setState(() {
        _appointments.add(appointment);
      });
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          _appointments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No appointments scheduled',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final appt = _appointments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),

                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(appt.patientName ?? 'Unknown Patient'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(appt.purpose),
                            Text(
                              '${DateFormat.yMMMd().format(appt.dateTime)} at ${DateFormat.jm().format(appt.dateTime)}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Status: ${appt.status}',
                              style: TextStyle(
                                color: (appt.status) == "completed"
                                    ? Colors.green
                                    : (appt.status) == "missed"
                                    ? Colors.red
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (appt.soundFile != null &&
                                appt.soundFile!.isNotEmpty)
                              TextButton.icon(
                                onPressed: () => _playAudio(appt.soundFile!),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Play Voice Note'),
                              ),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () async {
                                    await _databaseService
                                        .updateAppointmentStatus(
                                          appt.id,
                                          "completed",
                                        );
                                    _loadAppointments();
                                  },
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  label: const Text(
                                    "Completed",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () async {
                                    await _databaseService
                                        .updateAppointmentStatus(
                                          appt.id,
                                          "missed",
                                        );
                                    _loadAppointments();
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    "Missed",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () async {
                                    final shouldDelete = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Deletion'),
                                          content: const Text(
                                            'Are you sure you want to delete this appointment?',
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(
                                                  context,
                                                ).pop(false); // return false
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Delete'),
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (shouldDelete == true) {
                                      await _databaseService.deleteAppointment(
                                        appt.id,
                                      );
                                    }
                                    _loadAppointments();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),

                        isThreeLine: true,
                      ),
                    );
                  },
                ),

          // Floating Action Button
          Positioned(
            bottom: 30,
            right: 24,
            child: GestureDetector(
              onTap: _openAppointmentForm,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 48, 3, 209), // Blue
                      Color.fromARGB(255, 1, 115, 202), // Lighter blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.calendar_today_sharp,
                  color: Colors.white,
                  size: 30,
                  blendMode: BlendMode.srcOver,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() async {
    _notesController.dispose();
    _audioPlayer.dispose();

    super.dispose();
  }
}

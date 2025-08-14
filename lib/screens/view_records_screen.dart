import 'dart:async';

import 'package:chpsmamacare_main01/models/pregnancy_record.dart';
import 'package:chpsmamacare_main01/screens/add_record_screen.dart';
import 'package:chpsmamacare_main01/screens/pregnancy_record_detail_screen.dart';
import 'package:chpsmamacare_main01/services/database_service.dart';
import 'package:chpsmamacare_main01/utils/app_theme.dart';
import 'package:chpsmamacare_main01/utils/network_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ViewRecordsScreen extends StatefulWidget {
  final String? initialRecordId;

  const ViewRecordsScreen({super.key, this.initialRecordId});

  @override
  State<ViewRecordsScreen> createState() => _ViewRecordsScreenState();
}

class _ViewRecordsScreenState extends State<ViewRecordsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final DateFormat _dateFormat = DateFormat('dd MMM, yyyy');

  List<PregnancyRecord> _records = [];
  List<PregnancyRecord> _filteredRecords = [];

  String _selectedFilter = 'Name'; // ✅ Default filter
  final List<String> _filterOptions = [
    'Name',
    'Age',
    'ID',
  ]; // ✅ Available filters

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecords();
    _listenToFirestore(); // Start listening for updates
    _searchController.addListener(_filterRecords);
  }

  Future<void> _loadRecords() async {
    final localBox = await Hive.openBox<PregnancyRecord>('pregnancy_records');
    final localRecords = localBox.values.toList();

    setState(() {
      _records = localRecords;
      _filteredRecords = localRecords;
    });

    if (await isOnline()) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('pregnancy_records')
            .get();

        final firestoreRecords = snapshot.docs
            .map((doc) => PregnancyRecord.fromJson(doc.data()))
            .toList();

        // Merge local + firestore without duplicates
        final mergedRecords = {
          for (var r in [...localRecords, ...firestoreRecords]) r.id: r,
        }.values.toList();

        setState(() {
          _records = mergedRecords;
          _filteredRecords = mergedRecords;
        });

        // Sync Hive with merged data
        await localBox.clear();
        await localBox.addAll(mergedRecords);
      } catch (e) {
        print("Firestore fetch failed: $e");
      }
    } else {
      print("Offline — showing only local data");
    }
  }

  StreamSubscription? _firestoreSubscription;
  // To listen to firestore changes and sync changes across devices

  void _listenToFirestore() {
    _firestoreSubscription = FirebaseFirestore.instance
        .collection('pregnancy_records')
        .snapshots()
        .listen((snapshot) async {
          if (!mounted) return; // Prevents setState after dispose

          final remoteRecords = snapshot.docs
              .map((doc) => PregnancyRecord.fromJson(doc.data()))
              .toList();

          final localBox = await Hive.openBox<PregnancyRecord>(
            'pregnancy_records',
          );

          // Merge without duplicates (Firestore has priority)
          final mergedRecords = {
            for (var r in [...localBox.values, ...remoteRecords]) r.id: r,
          }.values.toList();

          await localBox.clear();
          await localBox.addAll(mergedRecords);

          if (mounted) {
            setState(() {
              _records = mergedRecords;
              _filteredRecords = mergedRecords;
            });
          }
        });
  }

  // filter search by name, age, id, etc
  void _filterRecords() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredRecords = List.from(_records));
      return;
    }

    setState(() {
      _filteredRecords = _records.where((r) {
        switch (_selectedFilter) {
          case 'Name':
            return r.motherName.toLowerCase().contains(query);
          case 'Age':
            return r.age.toString().contains(query);
          case 'ID':
            return (r.patientId ?? '').toLowerCase().contains(query);

          default:
            return false;
        }
      }).toList();
    });
  }

  // void _filterRecords() {
  //   final query = _searchController.text.trim().toLowerCase();
  //   if (query.isEmpty) {
  //     setState(() => _filteredRecords = List.from(_records));
  //     return;
  //   }
  //   setState(() {
  //     _filteredRecords = _records.where((r) {
  //       final name = r.motherName.toLowerCase();
  //       final id = (r.id ?? '').toLowerCase();
  //       final phone = (r.phone ?? '').toLowerCase();
  //       final midwife = (r.midwifeName ?? '').toLowerCase();
  //       final addr = (r.address ?? '').toLowerCase();
  //       final ageStr = r.age.toString(); // numeric

  //       return name.contains(query) ||
  //           id.contains(query) ||
  //           phone.contains(query) ||
  //           midwife.contains(query) ||
  //           addr.contains(query) ||
  //           ageStr.contains(query);
  //     }).toList();
  //   });
  //   // setState(() {
  //   //   _filteredRecords = _records.where((record) {
  //   //     return record.motherName.toLowerCase().contains(query);
  //   //   }).toList();
  //   // });
  // }

  @override
  void dispose() {
    _searchController.dispose();
    _firestoreSubscription?.cancel(); // ✅ Cancel Firestore listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupedRecords = <String, List<PregnancyRecord>>{};
    for (var record in _filteredRecords) {
      final patientKey = record.id ?? record.motherName;
      groupedRecords.putIfAbsent(patientKey, () => []).add(record);
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Pregnancy Records',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
          backgroundColor: AppColors.primary,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _loadRecords,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.refresh, color: Colors.white, size: 25),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Records list with top padding for floating search bar
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: _filteredRecords.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadRecords,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent:
                              200, // max width of each folder tile
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9, // height/width ratio
                        ),
                        itemCount: groupedRecords.length,
                        itemBuilder: (context, index) {
                          final entry = groupedRecords.entries.elementAt(index);
                          return _buildFolder(entry.key, entry.value);
                        },
                      ),
                    ),
            ),

            // Floating search bar
            Positioned(
              left: 16,
              right: 16,
              top: 20,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.18),
                      width: 1.0,
                    ),
                  ),

                  child: Row(
                    children: [
                      DropdownButton<String>(
                        value: _selectedFilter, // ✅ Current filter
                        items: _filterOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedFilter = value;
                              _filterRecords(); // ✅ Refresh results on change
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText:
                                'Search by $_selectedFilter...', // ✅ Dynamic placeholder
                            hintStyle: TextStyle(
                              color: Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.35),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Floating action button
            Positioned(
              bottom: 30,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddRecordScreen(
                        patientId: DateTime.now().millisecondsSinceEpoch
                            .toString(),
                      ),
                    ),
                  );
                },
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
                    Icons.add_box,
                    color: Colors.white,
                    size: 30,
                    blendMode: BlendMode.srcOver,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No pregnancy records found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first pregnancy record to get started',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No records match your search',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different name',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
  }

  //
  // Widget _buildFolder(String patientId, List<PregnancyRecord> records) {
  //   final firstRecord = records.first;
  //   return Card(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: ListTile(
  //       leading: Icon(Icons.folder, color: Colors.amber, size: 40),
  //       title: Text(
  //         firstRecord.motherName,
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       subtitle: Text('${records.length} record(s)'),
  //       trailing: Icon(Icons.arrow_forward_ios, size: 16),
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (_) => PatientFolderScreen(
  //               patientName: firstRecord.motherName,
  //               records: records,
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildFolder(String patientId, List<PregnancyRecord> records) {
    final firstRecord = records.first;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PregnancyRecordDetailScreen(record: firstRecord),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder, color: Colors.amber, size: 60),
          const SizedBox(height: 8),
          Text(
            firstRecord.motherName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            firstRecord.patientId ?? "No ID",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('dd MMM yyyy').format(firstRecord.createdAt),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(PregnancyRecord record) {
    final hasRecentDangerSigns = record.latestCheckup?.hasDangerSigns == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to record details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PregnancyRecordDetailScreen(record: record),
            ),
          ).then((_) => _loadRecords()); // Reload in case of updates

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Record details for ${record.motherName}')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    radius: 24,
                    child: const Icon(
                      Icons.pregnant_woman,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.motherName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: record.isHighRisk
                                    ? AppColors.warning.withOpacity(0.1)
                                    : AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Week ${record.currentWeek}',
                                style: TextStyle(
                                  color: record.isHighRisk
                                      ? AppColors.warning
                                      : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (hasRecentDangerSigns) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: AppColors.danger,
                                      size: 12,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Danger Signs',
                                      style: TextStyle(
                                        color: AppColors.danger,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[900],
                    size: 16,
                  ),
                ],
              ),

              const Divider(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LMP',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _dateFormat.format(record.lastMenstrualPeriod),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EDD',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _dateFormat.format(record.expectedDeliveryDate),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Checkups',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${record.checkups.length}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

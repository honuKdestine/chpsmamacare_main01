import 'package:chpsmamacare_main01/models/pregnancy_record.dart';
import 'package:chpsmamacare_main01/screens/pregnancy_record_detail_screen.dart';
import 'package:flutter/material.dart';

class PatientFolderScreen extends StatelessWidget {
  final String patientName;
  final List<PregnancyRecord> records;

  const PatientFolderScreen({
    super.key,
    required this.patientName,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$patientName\'s Records')),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return ListTile(
            title: Text('LMP: ${record.lastMenstrualPeriod}'),
            subtitle: Text('EDD: ${record.expectedDeliveryDate}'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PregnancyRecordDetailScreen(record: record),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

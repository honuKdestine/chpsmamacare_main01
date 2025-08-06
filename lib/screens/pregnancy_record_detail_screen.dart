import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/pregnancy_record.dart';
import 'add_record_screen.dart'; // Reuse for editing

class PregnancyRecordDetailScreen extends StatelessWidget {
  final PregnancyRecord record;

  const PregnancyRecordDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final DateFormat format = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Record: ${record.motherName}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            fontFamily: 'Montserrat',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddRecordScreen(existingRecord: record),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildDetailTile('Record ID', record.id.hashCode.toString()),
            _buildDetailTile('Created At', format.format(record.createdAt)),
            _buildDetailTile('Midwife', record.midwifeName),
            _buildDetailTile('Mother\'s Name', record.motherName),
            _buildDetailTile('Age', record.age.toString()),
            _buildPhoneTile('Phone', record.phone, context),
            _buildDetailTile('Address', record.address),
            _buildDetailTile('Gravida', record.gravida.toString()),
            _buildDetailTile('Parity', record.parity.toString()),
            _buildDetailTile(
              'Last Menstrual Period',
              format.format(record.lastMenstrualPeriod),
            ),
            _buildDetailTile(
              'Expected Delivery Date',
              format.format(record.expectedDeliveryDate),
            ),
            _buildDetailTile(
              'Medical History',
              record.medicalHistory ?? 'None',
            ),
            _buildDetailTile(
              'Family Illness',
              record.familyIllness ? 'Yes' : 'No',
            ),
            if (record.familyIllnessDetails != null &&
                record.familyIllnessDetails!.isNotEmpty)
              _buildDetailTile('Illness Details', record.familyIllnessDetails!),
            _buildDetailTile('Notes', record.notes ?? 'None'),
            if (record.testFilePath != null && record.testFilePath!.isNotEmpty)
              _buildFileViewerTile(
                'Test File',
                record.testFilePath!,
                record.testFileName,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16)),
        const Divider(height: 24),
      ],
    );
  }

  /// Builds a tile for viewing files with an open button
  Widget _buildFileViewerTile(String title, String filePath, String? fileName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(fileName ?? 'View File', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.visibility),
          label: Text('View File'),
          onPressed: () async {
            await OpenFile.open(filePath);
          },
        ),
        const Divider(height: 24),
      ],
    );
  }

  /// Builds a tile for phone numbers with a call button
  Widget _buildPhoneTile(
    String title,
    String phoneNumber,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(phoneNumber, style: TextStyle(fontSize: 16))),
            IconButton(
              icon: Icon(
                Icons.phone,
                color: const Color.fromARGB(255, 2, 116, 6),
              ),
              tooltip: 'Call $phoneNumber',
              onPressed: () async {
                final Uri url = Uri(scheme: 'tel', path: phoneNumber);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not launch dialer')),
                  );
                }
              },
            ),
          ],
        ),
        const Divider(height: 24),
      ],
    );
  }
}

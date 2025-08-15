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
    print('File paths: ${record.testFilePaths}');
    print('File names: ${record.testFileNames}');

    final DateFormat format = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Record: ${record.motherName}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            fontFamily: 'Montserrat',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddRecordScreen(
                    existingRecord: record,
                    patientId: record.patientId,
                  ),
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
            _buildDetailTile('Patient ID', record.patientId),
            _buildDetailTile('Created At', format.format(record.createdAt)),
            _buildDetailTile('Mother\'s Name', record.motherName),
            if (record.dateOfBirth != null)
              _buildDetailTile(
                'Date of Birth',
                format.format(record.dateOfBirth!),
              ),
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
            _buildDetailTile('Midwife\'s Name', record.midwifeName),

            if (record.testFilePaths != null &&
                record.testFilePaths!.isNotEmpty)
              _buildTestFilesSection(),
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
        Text(value, style: const TextStyle(fontSize: 16)),
        const Divider(height: 24),
      ],
    );
  }

  //Supports both local file paths & Firebase Storage URLs
  //Shows multiple files instead of one
  Widget _buildFileViewerTileList(
    String title,
    List<String> filePaths,
    List<String> fileNames,
  ) {
    // Keeping for backward compatibility but not used
    return const SizedBox.shrink();
  }

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
            Expanded(
              child: Text(phoneNumber, style: const TextStyle(fontSize: 16)),
            ),
            IconButton(
              icon: const Icon(
                Icons.phone,
                color: Color.fromARGB(255, 2, 116, 6),
              ),
              tooltip: 'Call $phoneNumber',
              onPressed: () async {
                final Uri url = Uri(scheme: 'tel', path: phoneNumber);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch dialer')),
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

  Widget _buildTestFilesSection() {
    final hasFiles =
        record.testFilePaths != null && record.testFilePaths!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Test Results / Test Files',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),

        if (!hasFiles)
          Text(
            'No test files available.',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),

        if (hasFiles)
          ...List.generate(record.testFilePaths!.length, (index) {
            final filePath = record.testFilePaths![index];
            final fileName =
                (record.testFileNames != null &&
                    index < record.testFileNames!.length)
                ? record.testFileNames![index]
                : 'Test File ${index + 1}';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: Row(
                children: [
                  Icon(_getFileIcon(fileName), color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to view file',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () => _openFile(filePath),
                  ),
                ],
              ),
            );
          }),

        const Divider(height: 24),
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _openFile(String filePath) async {
    try {
      if (filePath.startsWith('http')) {
        // Handle Firebase Storage URLs
        final Uri url = Uri.parse(filePath);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } else {
        // Handle local file paths
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          print('Failed to open file: ${result.message}');
        }
      }
    } catch (e) {
      print('Error opening file: $e');
    }
  }
}

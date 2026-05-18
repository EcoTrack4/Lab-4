import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Export Reports Screen - Generate and export wildlife compliance reports
class ExportReportsScreen extends StatefulWidget {
  const ExportReportsScreen({Key? key}) : super(key: key);

  @override
  State<ExportReportsScreen> createState() => _ExportReportsScreenState();
}

class _ExportReportsScreenState extends State<ExportReportsScreen> {
  String _selectedFormat = 'PDF';
  String _selectedPeriod = 'Monthly';
  bool _includePhotos = false;
  bool _includeGPS = true;

  final List<String> _formats = ['PDF', 'Excel', 'CSV'];
  final List<String> _periods = ['Weekly', 'Monthly', 'Quarterly', 'Annual'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Reports'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: AppColors.info,
                    width: 1.5,
                  ),
                ),
                color: AppColors.info.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Generate Reports',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Select format and period for export',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mediumGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Export Format
              _buildSectionHeader('Export Format'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _formats
                    .map((format) => FilterChip(
                          label: Text(format),
                          selected: _selectedFormat == format,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFormat = format;
                            });
                          },
                          selectedColor:
                              AppColors.primaryGreen.withOpacity(0.2),
                          backgroundColor: AppColors.lightGrey,
                          labelStyle: TextStyle(
                            color: _selectedFormat == format
                                ? AppColors.primaryGreen
                                : AppColors.mediumGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 28),

              // Report Period
              _buildSectionHeader('Report Period'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedPeriod,
                decoration: InputDecoration(
                  labelText: 'Period',
                  prefixIcon: const Icon(
                    Icons.calendar_month,
                    color: AppColors.primaryGreen,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _periods
                    .map((period) => DropdownMenuItem(
                          value: period,
                          child: Text(period),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                },
              ),
              const SizedBox(height: 28),

              // Report Options
              _buildSectionHeader('Include in Report'),
              const SizedBox(height: 12),
              _buildSwitchTile(
                icon: Icons.image_outlined,
                title: 'Include Photos',
                subtitle: 'Embed wildlife photos in report',
                value: _includePhotos,
                onChanged: (value) {
                  setState(() {
                    _includePhotos = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.location_on_outlined,
                title: 'Include GPS Coordinates',
                subtitle: 'Show location data in report',
                value: _includeGPS,
                onChanged: (value) {
                  setState(() {
                    _includeGPS = value;
                  });
                },
              ),
              const SizedBox(height: 28),

              // Recent Exports
              _buildSectionHeader('Recent Exports'),
              const SizedBox(height: 12),
              _buildExportCard(
                title: 'Monthly Report - April 2024',
                subtitle: 'PDF • 2.3 MB',
                date: 'May 1, 2024',
              ),
              _buildExportCard(
                title: 'Quarterly Report - Q1 2024',
                subtitle: 'Excel • 1.8 MB',
                date: 'Apr 1, 2024',
              ),
              const SizedBox(height: 28),

              // Export Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report exported successfully!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Generate & Export Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.lightGrey,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportCard({
    required String title,
    required String subtitle,
    required String date,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.lightGrey,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: AppColors.primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.download_outlined,
              color: AppColors.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}

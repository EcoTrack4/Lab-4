import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

/// Return Details Screen - View detailed information about a wildlife return
class ReturnDetailsScreen extends StatelessWidget {
  final String returnId;

  const ReturnDetailsScreen({
    Key? key,
    required this.returnId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Details'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Edit'),
                onTap: () {},
              ),
              PopupMenuItem(
                child: const Text('Print'),
                onTap: () {},
              ),
              PopupMenuItem(
                child: const Text('Share'),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppColors.success.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status: Approved',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Approved on May 5, 2024',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.success.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Wildlife Information
              _buildSectionHeader('Wildlife Information'),
              const SizedBox(height: 12),
              _buildInfoRow('Species', 'Oryx'),
              _buildInfoRow('Quantity', '1'),
              _buildInfoRow('Hunt Date', 'May 1, 2024'),
              const SizedBox(height: 24),

              // Location Information
              _buildSectionHeader('Location Details'),
              const SizedBox(height: 12),
              _buildInfoRow('Region', 'Kunene Region'),
              _buildInfoRow('GPS Coordinates', '-18.2341, 14.5234'),
              _buildInfoRow('Description', 'Northern Kunene Valley, near Etosha'),
              const SizedBox(height: 24),

              // Hunter Information
              _buildSectionHeader('Hunter Information'),
              const SizedBox(height: 12),
              _buildInfoRow('Name', 'Johannes Botha'),
              _buildInfoRow('License Number', 'PH-2024-001'),
              _buildInfoRow('Contact', '+264 81 234 5678'),
              const SizedBox(height: 24),

              // Photos
              _buildSectionHeader('Photos'),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildPhotoCard(),
                    _buildPhotoCard(),
                    _buildPhotoCard(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Officer Notes
              _buildSectionHeader('Officer Review Notes'),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: AppColors.lightGrey,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'All documentation verified and complete. Wildlife identification confirmed. Location data accurate. Approved for final submission.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.mediumGrey,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Download Report'),
                    ),
                  ),
                ],
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.mediumGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard() {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.lightGrey,
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: AppColors.mediumGrey,
        ),
      ),
    );
  }
}

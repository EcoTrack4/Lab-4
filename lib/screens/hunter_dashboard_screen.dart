import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

/// Professional Hunter Dashboard - Main page for hunters to submit and track returns
class HunterDashboardScreen extends StatefulWidget {
  const HunterDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HunterDashboardScreen> createState() => _HunterDashboardScreenState();
}

class _HunterDashboardScreenState extends State<HunterDashboardScreen> {
  int _selectedTabIndex = 0;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final supabase = Supabase.instance.client;
              final router = GoRouter.of(context);
              await supabase.auth.signOut();
              if (mounted) {
                router.go('/welcome');
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hunter Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/hunter-dashboard/profile'),
            tooltip: 'Profile',
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem<String>(
                value: 'offline',
                child: Text('Offline Status'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) {
              if (value == 'settings') {
                context.push('/hunter-dashboard/settings');
              } else if (value == 'offline') {
                context.push('/hunter-dashboard/offline-sync');
              } else if (value == 'logout') {
                _showLogoutDialog();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header in Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Welcome Back, Johannes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Professional Hunter License: PH-2024-001',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Kunene Region',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Stats Row
            const Text(
              'Your Returns Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildStatBox('This Year', '4', Icons.calendar_today, AppColors.info),
                  const SizedBox(width: 12),
                  _buildStatBox('Approved', '3', Icons.check_circle, AppColors.success),
                  const SizedBox(width: 12),
                  _buildStatBox('Pending', '1', Icons.schedule, AppColors.pending),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Main Action Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/hunter-dashboard/new-return'),
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Submit New Return',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Log your catch and submit for approval',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Links
            const Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickLinkCard(
                    'View History',
                    'Past submissions',
                    Icons.history,
                    AppColors.primaryGreen,
                    () => context.push('/hunter-dashboard/history'),
                  ),
                  const SizedBox(width: 12),
                  _buildQuickLinkCard(
                    'Offline Mode',
                    'Sync status',
                    Icons.cloud_sync,
                    AppColors.info,
                    () => context.push('/hunter-dashboard/offline-sync'),
                  ),
                  const SizedBox(width: 12),
                  _buildQuickLinkCard(
                    'License Info',
                    'Your details',
                    Icons.badge,
                    AppColors.accentGreen,
                    () => context.push('/hunter-dashboard/profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Recent Returns
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Returns',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/hunter-dashboard/history'),
                  child: const Text('View All →'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildReturnItem(
              'Oryx',
              'Kunene Region',
              'May 1, 2024',
              'Approved',
              () => context.push('/hunter-dashboard/return-status/1'),
            ),
            const SizedBox(height: 12),
            _buildReturnItem(
              'Kudu',
              'Kunene Region',
              'Apr 28, 2024',
              'Approved',
              () => context.push('/hunter-dashboard/return-status/2'),
            ),
            const SizedBox(height: 12),
            _buildReturnItem(
              'Springbok',
              'Kunene Region',
              'Apr 15, 2024',
              'Pending',
              () => context.push('/hunter-dashboard/return-status/3'),
            ),
            const SizedBox(height: 28),

            // Reminders Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.info,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Important Reminders',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '✓ Submit returns within 30 days of hunt\n'
                    '✓ Provide accurate location data\n'
                    '✓ Include high-quality photos\n'
                    '✓ Works offline - syncs automatically',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.mediumGrey,
                      height: 1.75,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
          switch (index) {
            case 0:
              context.go('/hunter-home');
              break;
            case 1:
              context.push('/hunter-dashboard/new-return');
              break;
            case 2:
              context.push('/hunter-dashboard/history');
              break;
            case 3:
              context.push('/hunter-dashboard/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'New Return',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGrey.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinkCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 150,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkGrey.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
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
      ),
    );
  }

  Widget _buildReturnItem(String species, String location, String date, String status, VoidCallback onTap) {
    final statusColor = status == 'Approved' ? AppColors.success : AppColors.pending;
    final statusIcon = status == 'Approved' ? Icons.check_circle : Icons.schedule;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGrey.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(statusIcon, color: statusColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    species,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$location • $date',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

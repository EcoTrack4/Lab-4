import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

/// Hunter Home Screen - Landing page for logged in hunters
class HunterHomeScreen extends StatefulWidget {
  const HunterHomeScreen({Key? key}) : super(key: key);

  @override
  State<HunterHomeScreen> createState() => _HunterHomeScreenState();
}

class _HunterHomeScreenState extends State<HunterHomeScreen> {
  int _selectedTabIndex = 0;

  void _navigateTo(String route) {
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = [
      'Welcome Back, Hunter',
      'Your Returns',
      'Reports & Sync',
      'Profile',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    'EcoTrack Hunter',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quick access to returns, offline mode, and your profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGrey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  _buildLandingPage(context),
                  _buildReturnsPage(),
                  _buildReportsPage(),
                  _buildProfilePage(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.mediumGrey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Returns',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Reports',
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

  Widget _buildLandingPage(BuildContext context) {
    final actions = [
      _HomeAction(
        label: 'Submit Return',
        icon: Icons.add_circle_outline,
        color: AppColors.primaryGreen,
        onTap: () => _navigateTo('/hunter-dashboard/new-return'),
      ),
      _HomeAction(
        label: 'History',
        icon: Icons.history,
        color: AppColors.info,
        onTap: () => _navigateTo('/hunter-dashboard/history'),
      ),
      _HomeAction(
        label: 'Offline Sync',
        icon: Icons.cloud_sync,
        color: AppColors.pending,
        onTap: () => _navigateTo('/hunter-dashboard/offline-sync'),
      ),
      _HomeAction(
        label: 'My Profile',
        icon: Icons.person,
        color: AppColors.accentGreen,
        onTap: () => _navigateTo('/hunter-dashboard/profile'),
      ),
      _HomeAction(
        label: 'Settings',
        icon: Icons.settings,
        color: AppColors.darkGrey,
        onTap: () => _navigateTo('/hunter-dashboard/settings'),
      ),
      _HomeAction(
        label: 'Help',
        icon: Icons.help_outline,
        color: AppColors.info,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Need Help?'),
              content: const Text('Contact your administrator or use the support channels for assistance.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: AppLogo(
                size: 90,
                showText: false,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Hunter Home',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the cards below to open sections with focused actions and avoid too much scrolling.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mediumGrey,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: actions.map((action) => action).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Returns',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 16),
          ReturnItemCard(
            species: 'Oryx',
            location: 'Kunene Region',
            date: 'May 1, 2024',
            status: 'Approved',
            onTap: () => _navigateTo('/hunter-dashboard/return-status/1'),
          ),
          ReturnItemCard(
            species: 'Kudu',
            location: 'Kunene Region',
            date: 'Apr 28, 2024',
            status: 'Approved',
            onTap: () => _navigateTo('/hunter-dashboard/return-status/2'),
          ),
          ReturnItemCard(
            species: 'Springbok',
            location: 'Kunene Region',
            date: 'Apr 15, 2024',
            status: 'Pending',
            onTap: () => _navigateTo('/hunter-dashboard/return-status/3'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reports & Sync',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: StatCard(
                  label: 'Pending Sync',
                  value: '2',
                  icon: Icons.cloud_queue,
                  color: AppColors.pending,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Submitted',
                  value: '6',
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DashboardCard(
            title: 'View History',
            subtitle: 'See your submissions',
            icon: Icons.history,
            backgroundColor: const Color(0xFFFFFFFF),
            onTap: () => _navigateTo('/hunter-dashboard/history'),
          ),
          const SizedBox(height: 12),
          DashboardCard(
            title: 'View Sync Status',
            subtitle: 'Check pending data sync',
            icon: Icons.cloud_sync,
            backgroundColor: const Color(0xFFFFFFFF),
            onTap: () => _navigateTo('/hunter-dashboard/offline-sync'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Johannes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Professional Hunter License: PH-2024-001',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kunene Region',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _navigateTo('/hunter-dashboard/settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Account Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => _navigateTo('/hunter-dashboard/profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(color: AppColors.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Full Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeAction({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 72) / 2,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

/// Officer Home Screen - Landing page for logged in permit officers
class OfficerHomeScreen extends StatefulWidget {
  const OfficerHomeScreen({Key? key}) : super(key: key);

  @override
  State<OfficerHomeScreen> createState() => _OfficerHomeScreenState();
}

class _OfficerHomeScreenState extends State<OfficerHomeScreen> {
  int _selectedTabIndex = 0;

  void _navigateTo(String route) {
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const Text(
                    'EcoTrack Officer',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Access pending reviews, search returns, and manage compliance efficiently.',
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
                  _buildLandingPage(),
                  _buildReviewPage(),
                  _buildExportPage(),
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
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            activeIcon: Icon(Icons.assessment),
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

  Widget _buildLandingPage() {
    final actions = [
      _HomeAction(
        label: 'Search Returns',
        icon: Icons.search,
        color: AppColors.primaryGreen,
        onTap: () => _navigateTo('/officer-dashboard/search'),
      ),
      _HomeAction(
        label: 'Pending Reviews',
        icon: Icons.schedule,
        color: AppColors.pending,
        onTap: () => _navigateTo('/officer-dashboard/search'),
      ),
      _HomeAction(
        label: 'Export Report',
        icon: Icons.download,
        color: AppColors.info,
        onTap: () => _navigateTo('/officer-dashboard/export-reports'),
      ),
      _HomeAction(
        label: 'My Profile',
        icon: Icons.person,
        color: AppColors.accentGreen,
        onTap: () => _navigateTo('/officer-dashboard/profile'),
      ),
      _HomeAction(
        label: 'Settings',
        icon: Icons.settings,
        color: AppColors.darkGrey,
        onTap: () => _navigateTo('/officer-dashboard/settings'),
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
              content: const Text('Use the search or reports tabs to find records faster, or contact your administrator.'),
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
            'Officer Home',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a section below to open a dedicated screen and avoid too much scrolling.',
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
            children: actions,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pending Reviews',
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
            date: 'May 5, 2024',
            status: 'Pending',
            onTap: () => _navigateTo('/officer-dashboard/return-details/1'),
          ),
          ReturnItemCard(
            species: 'Kudu',
            location: 'Erongo Region',
            date: 'May 4, 2024',
            status: 'Pending',
            onTap: () => _navigateTo('/officer-dashboard/return-details/2'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reports & Exports',
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
                  label: 'Approved',
                  value: '142',
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Rejected',
                  value: '5',
                  icon: Icons.cancel,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DashboardCard(
            title: 'Export Latest',
            subtitle: 'Generate compliance reports',
            icon: Icons.file_download,
            backgroundColor: const Color(0xFFFFFFFF),
            onTap: () => _navigateTo('/officer-dashboard/export-reports'),
          ),
          const SizedBox(height: 12),
          DashboardCard(
            title: 'Search records',
            subtitle: 'Filter and review returns',
            icon: Icons.search,
            backgroundColor: const Color(0xFFFFFFFF),
            onTap: () => _navigateTo('/officer-dashboard/search'),
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
                    'Petrus',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ministry of Environment, Forestry & Tourism',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Wildlife Permit Processing Officer',
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
              onPressed: () => _navigateTo('/officer-dashboard/settings'),
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
              onPressed: () => _navigateTo('/officer-dashboard/profile'),
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

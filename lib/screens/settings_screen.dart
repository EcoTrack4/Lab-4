import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

/// Settings Screen - User preferences and app settings
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _offlineModeEnabled = true;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Section
            _buildSectionGroup('General', [
              _buildSettingItem(
                icon: Icons.language,
                title: 'Language',
                subtitle: _selectedLanguage,
                onTap: () => _showLanguageDialog(),
              ),
              _buildSettingItem(
                icon: Icons.color_lens_outlined,
                title: 'Theme',
                subtitle: 'Light (Green)',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionGroup('Notifications', [
              _buildToggleSetting(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive updates about your returns',
                value: _notificationsEnabled,
                onChanged: (value) => setState(() => _notificationsEnabled = value),
              ),
              _buildToggleSetting(
                icon: Icons.mail_outline,
                title: 'Email Alerts',
                subtitle: 'Send updates via email',
                value: true,
                onChanged: (value) {},
              ),
            ]),
            const SizedBox(height: 24),

            // Data & Privacy Section
            _buildSectionGroup('Data & Privacy', [
              _buildToggleSetting(
                icon: Icons.cloud_download_outlined,
                title: 'Offline Sync',
                subtitle: 'Enable offline mode and sync data',
                value: _offlineModeEnabled,
                onChanged: (value) => setState(() => _offlineModeEnabled = value),
              ),
              _buildToggleSetting(
                icon: Icons.fingerprint,
                title: 'Biometric Login',
                subtitle: 'Use fingerprint or face recognition',
                value: _biometricEnabled,
                onChanged: (value) => setState(() => _biometricEnabled = value),
              ),
              _buildSettingItem(
                icon: Icons.storage_outlined,
                title: 'Cache & Data',
                subtitle: 'Clear app cache (125 MB)',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache cleared')),
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),

            // About Section
            _buildSectionGroup('About', [
              _buildSettingItem(
                icon: Icons.info_outlined,
                title: 'App Version',
                subtitle: 'v1.0.0',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.gavel_outlined,
                title: 'Terms of Service',
                subtitle: 'View legal terms',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'View privacy information',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),

            // Account Section
            _buildSectionGroup('Account', [
              _buildSettingItem(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => _showLogoutDialog(),
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

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

  Widget _buildSectionGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
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
          child: Column(
            children: List.generate(
              items.length,
              (index) => Column(
                children: [
                  items[index],
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      color: AppColors.lightGrey.withOpacity(0.5),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color textColor = AppColors.darkGrey,
    Color iconColor = AppColors.primaryGreen,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
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
            Icon(Icons.chevron_right, color: AppColors.lightGrey, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSetting({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 22),
          ),
          const SizedBox(width: 14),
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
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Afrikaans'),
              value: 'Afrikaans',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Oshiwambo'),
              value: 'Oshiwambo',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

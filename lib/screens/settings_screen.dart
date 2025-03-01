import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF024A59),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildSection(
            'Account Settings',
            [
              _buildSettingTile(
                icon: Icons.person,
                title: 'Profile Information',
                subtitle: 'Update your personal details',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              _buildSettingTile(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Configure alert preferences',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // Toggle notifications
                  },
                  activeColor: const Color(0xFF024A59),
                ),
              ),
              _buildSettingTile(
                icon: Icons.lock,
                title: 'Privacy & Security',
                subtitle: 'Manage your security settings',
                onTap: () {
                  // Navigate to privacy settings
                },
              ),
            ],
          ),
          _buildSection(
            'Support',
            [
              _buildSettingTile(
                icon: Icons.help,
                title: 'Help Center',
                subtitle: 'Get help and support',
                onTap: () {
                  // Navigate to help center
                },
              ),
              _buildSettingTile(
                icon: Icons.info,
                title: 'About',
                subtitle: 'App information and version',
                onTap: () {
                  // Show about dialog
                },
              ),
              _buildSettingTile(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                textColor: Colors.red,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Clear any stored user data here if needed
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF024A59),
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? const Color(0xFF024A59),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

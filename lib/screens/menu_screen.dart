import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../screens/patient_list_screen.dart';
import '../screens/critical_patients_screen.dart';
import '../screens/tests_screen.dart';

class MenuScreen extends StatelessWidget {
  final List<Patient> patients;

  const MenuScreen({
    super.key,
    required this.patients,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: const Color(0xFF024A59),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuSection(
            context,
            'Patient Management',
            [
              _buildMenuItem(
                icon: Icons.people,
                title: 'All Patients',
                subtitle: 'View and manage all patients',
                onTap: () => _navigateToPatientList(context),
              ),
              _buildMenuItem(
                icon: Icons.warning,
                title: 'Critical Patients',
                subtitle: 'View patients needing immediate attention',
                onTap: () => _navigateToCriticalPatients(context),
              ),
              _buildMenuItem(
                icon: Icons.medical_services,
                title: 'Medical Tests',
                subtitle: 'View and manage patient tests',
                onTap: () => _navigateToTests(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMenuSection(
            context,
            'Settings',
            [
              _buildMenuItem(
                icon: Icons.settings,
                title: 'App Settings',
                subtitle: 'Configure app preferences',
                onTap: () {
                  // Navigate to settings
                },
              ),
              _buildMenuItem(
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get assistance and view FAQs',
                onTap: () {
                  // Navigate to help
                },
              ),
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                isDestructive: true,
                onTap: () {
                  // Handle logout
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToPatientList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PatientListScreen(),
      ),
    );
  }

  void _navigateToCriticalPatients(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CriticalPatientsScreen(patients: patients),
      ),
    );
  }

  void _navigateToTests(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestsScreen(patients: patients),
      ),
    );
  }

  Widget _buildMenuSection(
      BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF024A59),
          ),
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF024A59),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

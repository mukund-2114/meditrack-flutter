import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/patient_list_screen.dart';
import '../screens/tests_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/menu_screen.dart';
import '../models/patient.dart';

class BottomNavController extends StatefulWidget {
  const BottomNavController({super.key});

  @override
  State<BottomNavController> createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController> {
  int _selectedIndex = 0;

  // Create a list of demo patients
  final List<Patient> _patients = [
    Patient(
      id: '1',
      name: 'John Doe',
      age: 45,
      condition: 'Hypertension',
      lastChecked: DateTime.now(),
      status: PatientStatus.critical,
      careNotes: 'Needs immediate attention, BP: 180/110',
    ),
    Patient(
      id: '2',
      name: 'Jane Smith',
      age: 32,
      condition: 'Diabetes Type 2',
      lastChecked: DateTime.now().subtract(const Duration(days: 2)),
      status: PatientStatus.stable,
      careNotes: 'Regular insulin checks, diet controlled',
    ),
    Patient(
      id: '3',
      name: 'Robert Johnson',
      age: 58,
      condition: 'Heart Disease',
      lastChecked: DateTime.now().subtract(const Duration(hours: 12)),
      status: PatientStatus.critical,
      careNotes: 'Recent chest pain, ECG needed',
    ),
    Patient(
      id: '4',
      name: 'Mary Williams',
      age: 28,
      condition: 'Asthma',
      lastChecked: DateTime.now().subtract(const Duration(days: 1)),
      status: PatientStatus.moderate,
      careNotes: 'Seasonal allergies affecting condition',
    ),
    Patient(
      id: '5',
      name: 'David Brown',
      age: 50,
      condition: 'Arthritis',
      lastChecked: DateTime.now().subtract(const Duration(days: 5)),
      status: PatientStatus.stable,
      careNotes: 'Physical therapy ongoing, good progress',
    ),
    Patient(
      id: '6',
      name: 'Sarah Davis',
      age: 41,
      condition: 'Pneumonia',
      lastChecked: DateTime.now().subtract(const Duration(hours: 6)),
      status: PatientStatus.critical,
      careNotes: 'Oxygen levels need monitoring',
    ),
    Patient(
      id: '7',
      name: 'Michael Wilson',
      age: 35,
      condition: 'Post-Surgery Recovery',
      lastChecked: DateTime.now().subtract(const Duration(days: 3)),
      status: PatientStatus.moderate,
      careNotes: 'Wound healing well, physiotherapy started',
    ),
    Patient(
      id: '8',
      name: 'Emma Taylor',
      age: 62,
      condition: 'COPD',
      lastChecked: DateTime.now().subtract(const Duration(days: 1)),
      status: PatientStatus.moderate,
      careNotes: 'Regular nebulizer treatment',
    ),
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(patients: _patients),
      const ProfileScreen(),
      TestsScreen(patients: _patients),
      MenuScreen(patients: _patients),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF024A59),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: 'Tests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'Menu',
            ),
          ],
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/patient_card.dart';
import '../models/patient.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Patient> _filteredPatients = [];

  // Dummy data for demonstration
  final List<Patient> _patients = [
    Patient(
      id: '1',
      userId: 'user123',
      name: 'John Doe',
      dob: DateTime(1978, 5, 15),
      gender: 'Male',
      condition: 'Hypertension',
      lastChecked: DateTime.now(),
      status: PatientStatus.critical,
    ),
    Patient(
      id: '2',
      userId: 'user123',
      name: 'Jane Smith',
      dob: DateTime(1991, 8, 22),
      gender: 'Female',
      condition: 'Diabetes',
      lastChecked: DateTime.now(),
      status: PatientStatus.stable,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredPatients = _patients;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchPatients(String query) {
    setState(() {
      _filteredPatients = _patients.where((patient) {
        final nameLower = patient.name.toLowerCase();
        final conditionLower = patient.condition.toLowerCase();
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower) ||
            conditionLower.contains(searchLower) ||
            patient.age.toString().contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient List'),
        backgroundColor: const Color(0xFF024A59),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search patients...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchPatients('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF024A59)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF024A59), width: 2),
                ),
              ),
              onChanged: _searchPatients,
            ),
          ),
          Expanded(
            child: _filteredPatients.isEmpty
                ? const Center(
                    child: Text(
                      'No patients found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _filteredPatients.length,
                    itemBuilder: (context, index) {
                      return PatientCard(patient: _filteredPatients[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

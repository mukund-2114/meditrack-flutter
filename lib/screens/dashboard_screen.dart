import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../widgets/patient_card.dart';
import 'add_patient_screen.dart';

class DashboardScreen extends StatelessWidget {
  final List<Patient> patients;

  const DashboardScreen({
    super.key,
    required this.patients,
  });

  @override
  Widget build(BuildContext context) {
    final criticalPatients =
        patients.where((p) => p.status == PatientStatus.critical).toList();
    final moderatePatients =
        patients.where((p) => p.status == PatientStatus.moderate).toList();
    final stablePatients =
        patients.where((p) => p.status == PatientStatus.stable).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MediTrack Dashboard'),
        backgroundColor: const Color(0xFF024A59),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildSummaryCard(
                    'Critical',
                    criticalPatients.length,
                    Colors.red,
                    Icons.warning,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    'Moderate',
                    moderatePatients.length,
                    Colors.orange,
                    Icons.info,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    'Stable',
                    stablePatients.length,
                    Colors.green,
                    Icons.check_circle,
                  ),
                ],
              ),
            ),

            // Critical Patients Section
            if (criticalPatients.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Critical Patients',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              ...criticalPatients
                  .map((patient) => PatientCard(patient: patient)),
            ],

            // Moderate Patients Section
            if (moderatePatients.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Moderate Patients',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
              ...moderatePatients
                  .map((patient) => PatientCard(patient: patient)),
            ],

            // Stable Patients Section
            if (stablePatients.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Stable Patients',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              ...stablePatients.map((patient) => PatientCard(patient: patient)),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPatientScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF024A59),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, int count, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

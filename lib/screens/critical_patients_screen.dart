import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../widgets/patient_card.dart';

class CriticalPatientsScreen extends StatelessWidget {
  final List<Patient> patients;

  const CriticalPatientsScreen({
    super.key,
    required this.patients,
  });

  @override
  Widget build(BuildContext context) {
    final criticalPatients =
        patients.where((p) => p.status == PatientStatus.critical).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Critical Patients'),
        backgroundColor: const Color(0xFF024A59),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Critical Patients (${criticalPatients.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: criticalPatients.isEmpty
                ? const Center(
                    child: Text(
                      'No critical patients',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: criticalPatients.length,
                    itemBuilder: (context, index) {
                      return PatientCard(patient: criticalPatients[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

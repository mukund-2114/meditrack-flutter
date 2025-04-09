import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../widgets/patient_card.dart';
import 'add_patient_screen.dart';

class DashboardScreen extends StatelessWidget {
  final List<Patient> patients;
  final VoidCallback? onRefresh;

  const DashboardScreen({
    super.key,
    required this.patients,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final criticalPatients =
        patients.where((p) => p.status == PatientStatus.critical).toList();
    final stablePatients =
        patients.where((p) => p.status == PatientStatus.stable).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MediTrack Dashboard'),
        backgroundColor: const Color(0xFF024A59),
        foregroundColor: Colors.white,
        actions: [
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRefresh,
              tooltip: 'Refresh data',
            ),
        ],
      ),
      body: patients.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No patients found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add patients to get started',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (onRefresh != null)
                    ElevatedButton.icon(
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF024A59),
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            )
          : SingleChildScrollView(
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
                        .map((patient) => PatientCard(
                              patient: patient,
                              onRefresh: onRefresh,
                            )),
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
                    ...stablePatients.map((patient) => PatientCard(
                          patient: patient,
                          onRefresh: onRefresh,
                        )),
                  ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPatientScreen(),
            ),
          );
          if (result != null && onRefresh != null) {
            onRefresh!();
          }
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

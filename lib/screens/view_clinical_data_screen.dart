import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient.dart';
import '../models/clinical_data.dart';
import 'add_clinical_data_screen.dart';

class ViewClinicalDataScreen extends StatelessWidget {
  final Patient patient;

  const ViewClinicalDataScreen({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Data'),
        backgroundColor: const Color(0xFF024A59),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Patient Info Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient: ${patient.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Age: ${patient.age}'),
                  Text('Condition: ${patient.condition}'),
                ],
              ),
            ),
          ),
          // Clinical Data List
          Expanded(
            child: patient.clinicalData.isEmpty
                ? const Center(
                    child: Text(
                      'No clinical data available',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: patient.clinicalData.length,
                    itemBuilder: (context, index) {
                      final data = patient.clinicalData[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(data.type.name),
                          subtitle: Text(
                            'Date: ${_formatDateTime(data.testDate)}\n'
                            'Value: ${data.readingValue} ${data.unitValue}',
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddClinicalDataScreen(patient: patient),
            ),
          );
        },
        backgroundColor: const Color(0xFF024A59),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
}

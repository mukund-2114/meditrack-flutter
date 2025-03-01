import 'package:flutter/material.dart';
import '../models/patient.dart';

class TestsScreen extends StatelessWidget {
  final List<Patient> patients;

  const TestsScreen({
    super.key,
    required this.patients,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Tests'),
        backgroundColor: const Color(0xFF024A59),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search tests...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Implement filter functionality
                  },
                ),
              ],
            ),
          ),

          // Tests List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                return _buildTestCard(
                  'Regular Checkup',
                  patient.name,
                  patient.lastChecked,
                  TestStatus.pending,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add test screen
        },
        backgroundColor: const Color(0xFF024A59),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTestCard(
    String testName,
    String patientName,
    DateTime dateTime,
    TestStatus status,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF024A59),
          child: Icon(Icons.medical_services, color: Colors.white),
        ),
        title: Text(testName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patient: $patientName'),
            Text(
              'Date: ${dateTime.day}/${dateTime.month}/${dateTime.year}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: _buildStatusChip(status),
        onTap: () {
          // Navigate to test details
        },
      ),
    );
  }

  Widget _buildStatusChip(TestStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 12,
        ),
      ),
    );
  }
}

enum TestStatus {
  pending,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case TestStatus.pending:
        return 'Pending';
      case TestStatus.completed:
        return 'Completed';
      case TestStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case TestStatus.pending:
        return Colors.orange;
      case TestStatus.completed:
        return Colors.green;
      case TestStatus.cancelled:
        return Colors.red;
    }
  }
}

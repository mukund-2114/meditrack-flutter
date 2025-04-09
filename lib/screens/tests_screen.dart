import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/clinical_data.dart';
import '../services/clinical_data_service.dart';
import 'test_details_screen.dart';
import 'package:intl/intl.dart';

class TestsScreen extends StatefulWidget {
  final List<Patient> patients;

  const TestsScreen({
    super.key,
    required this.patients,
  });

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  bool _isLoading = true;
  String _error = '';
  List<ClinicalData> _allTests = [];
  List<ClinicalData> _filteredTests = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllTests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTests(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTests = _allTests;
      } else {
        _filteredTests = _allTests.where((test) {
          final patient = widget.patients.firstWhere(
            (p) => p.id == test.patientId,
            orElse: () => Patient(
              name: 'Unknown Patient',
              userId: 'unknown',
              dob: DateTime(1900),
              gender: 'Unknown',
              condition: 'Unknown',
              status: PatientStatus.stable,
            ),
          );
          
          final testType = test.type.name.toLowerCase();
          final patientName = patient.name.toLowerCase();
          final date = DateFormat('dd/MM/yyyy').format(test.testDate).toLowerCase();
          final searchLower = query.toLowerCase();

          return testType.contains(searchLower) ||
              patientName.contains(searchLower) ||
              date.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _loadAllTests() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      List<ClinicalData> allTests = [];
      
      // Load tests for each patient
      for (var patient in widget.patients) {
        if (patient.id != null) {
          final result = await ClinicalDataService.getTestsByPatientId(patient.id!);
          if (result['success']) {
            allTests.addAll(result['data'] as List<ClinicalData>);
          }
        }
      }

      if (mounted) {
        setState(() {
          _allTests = allTests;
          _filteredTests = allTests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Tests'),
        backgroundColor: const Color(0xFF024A59),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllTests,
          ),
        ],
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
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by test type, patient or date...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterTests('');
                              },
                            )
                          : null,
                    ),
                    onChanged: _filterTests,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // TODO: Implement filter functionality
                  },
                ),
              ],
            ),
          ),

          // Tests List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAllTests,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF024A59),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredTests.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.isEmpty
                                      ? 'No tests found'
                                      : 'No tests match your search',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _filteredTests.length,
                            itemBuilder: (context, index) {
                              final test = _filteredTests[index];
                              final patient = widget.patients.firstWhere(
                                (p) => p.id == test.patientId,
                                orElse: () => Patient(
                                  name: 'Unknown Patient',
                                  userId: 'unknown',
                                  dob: DateTime(1900),
                                  gender: 'Unknown',
                                  condition: 'Unknown',
                                  status: PatientStatus.stable,
                                ),
                              );
                              return _buildTestCard(
                                test.type.name,
                                patient.name,
                                test.testDate,
                                test.criticalFlag ? TestStatus.critical : TestStatus.completed,
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add test screen
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
          final test = _allTests.firstWhere(
            (t) => t.type.name == testName && t.testDate == dateTime,
          );
          final patient = widget.patients.firstWhere(
            (p) => p.id == test.patientId,
            orElse: () => Patient(
              name: 'Unknown Patient',
              userId: 'unknown',
              dob: DateTime(1900),
              gender: 'Unknown',
              condition: 'Unknown',
              status: PatientStatus.stable,
            ),
          );
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestDetailsScreen(
                test: test,
                patient: patient,
              ),
            ),
          ).then((refreshNeeded) {
            if (refreshNeeded == true) {
              _loadAllTests();
            }
          });
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
  critical;

  String get label {
    switch (this) {
      case TestStatus.pending:
        return 'Pending';
      case TestStatus.completed:
        return 'Normal';
      case TestStatus.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case TestStatus.pending:
        return Colors.orange;
      case TestStatus.completed:
        return Colors.green;
      case TestStatus.critical:
        return Colors.red;
    }
  }
}

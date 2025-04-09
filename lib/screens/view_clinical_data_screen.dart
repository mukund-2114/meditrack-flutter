import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient.dart';
import '../models/clinical_data.dart';
import '../services/clinical_data_service.dart';
import '../config/api_config.dart';
import 'dart:async';
import 'add_clinical_data_screen.dart';
import 'test_details_screen.dart';

class ViewClinicalDataScreen extends StatefulWidget {
  final Patient patient;

  const ViewClinicalDataScreen({
    super.key,
    required this.patient,
  });

  @override
  State<ViewClinicalDataScreen> createState() => _ViewClinicalDataScreenState();
}

class _ViewClinicalDataScreenState extends State<ViewClinicalDataScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<ClinicalData> _clinicalData = [];
  bool _isRetrying = false;
  int _retryCount = 0;
  bool _isCheckingApiAvailability = false;

  @override
  void initState() {
    super.initState();
    _loadClinicalData();
  }

  Future<void> _loadClinicalData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _isRetrying = false;
      _retryCount = 0;
    });

    await _fetchClinicalData();
  }

  Future<void> _fetchClinicalData() async {
    if (!mounted) return;

    try {
      // Check API availability first
      if (!_isRetrying) {
        setState(() {
          _isCheckingApiAvailability = true;
        });

        final bool isApiAvailable = await ApiConfig.checkApiAvailability();

        if (!mounted) return;

        setState(() {
          _isCheckingApiAvailability = false;
        });

        if (!isApiAvailable) {
          setState(() {
            _hasError = true;
            _errorMessage =
                'API server is not available. Please try again later.';
            _isLoading = false;
          });
          return;
        }
      }

      // Use the clinical data service to fetch data
      final result =
          await ClinicalDataService.getTestsByPatientId(widget.patient.id!);

      if (!mounted) return;

      if (result['success']) {
        setState(() {
          _clinicalData = result['data'];
          _isLoading = false;
          _retryCount = 0;
        });
      } else {
        // Handle empty data with retry
        if (result['data'] != null &&
            (result['data'] as List).isEmpty &&
            _retryCount < 2) {
          _retryWithDelay();
          return;
        }

        setState(() {
          _hasError = true;
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      if (_retryCount < 3) {
        _retryWithDelay();
        return;
      }

      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
        _isRetrying = false;
      });
    }
  }

  void _retryWithDelay() {
    if (!mounted) return;

    setState(() {
      _isRetrying = true;
      _retryCount++;
    });

    // Exponential backoff for retries: 2s, 4s, 8s
    final delay = Duration(seconds: 2 * _retryCount);

    print(
        'Retrying clinical data fetch (attempt $_retryCount) after ${delay.inSeconds}s delay');

    Timer(delay, () {
      if (mounted) {
        _fetchClinicalData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Data'),
        backgroundColor: const Color(0xFF024A59),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadClinicalData,
            tooltip: 'Refresh data',
          ),
        ],
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
                    'Patient: ${widget.patient.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Age: ${widget.patient.age}'),
                  // Text('Condition: ${widget.patient.condition}'),
                ],
              ),
            ),
          ),

          // Clinical Data List
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          _isRetrying
                              ? 'Retrying... (Attempt $_retryCount)'
                              : _isCheckingApiAvailability
                                  ? 'Checking server availability...'
                                  : 'Loading clinical data...',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _hasError
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
                              'Error: $_errorMessage',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadClinicalData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF024A59),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _clinicalData.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medical_services_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No clinical data available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Add clinical data using the + button below',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _clinicalData.length,
                            itemBuilder: (context, index) {
                              final test = _clinicalData[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: test.criticalFlag
                                        ? Colors.red
                                        : const Color(0xFF024A59),
                                    child: const Icon(
                                      Icons.medical_services,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(test.type.name),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Reading: ${test.reading} ${test.type.unit}',
                                      ),
                                      Text(
                                        'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(test.testDate)}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: test.criticalFlag
                                          ? Colors.red.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: test.criticalFlag
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                    child: Text(
                                      test.criticalFlag ? 'Critical' : 'Normal',
                                      style: TextStyle(
                                        color: test.criticalFlag
                                            ? Colors.red
                                            : Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TestDetailsScreen(
                                          test: test,
                                          patient: widget.patient,
                                        ),
                                      ),
                                    ).then((refreshNeeded) {
                                      if (refreshNeeded == true) {
                                        _loadClinicalData();
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddClinicalDataScreen(patient: widget.patient),
                  ),
                ).then((_) =>
                    _loadClinicalData()); // Refresh after adding new data
              },
        backgroundColor: _isLoading ? Colors.grey : const Color(0xFF024A59),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
}

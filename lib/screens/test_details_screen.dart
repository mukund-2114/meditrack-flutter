import 'package:flutter/material.dart';
import '../models/clinical_data.dart';
import '../models/patient.dart';
import '../services/clinical_data_service.dart';

class TestDetailsScreen extends StatefulWidget {
  final ClinicalData test;
  final Patient patient;

  const TestDetailsScreen({
    super.key,
    required this.test,
    required this.patient,
  });

  @override
  State<TestDetailsScreen> createState() => _TestDetailsScreenState();
}

class _TestDetailsScreenState extends State<TestDetailsScreen> {
  bool _isEditing = false;
  bool _isLoading = false;
  String _error = '';
  late TextEditingController _readingController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _readingController = TextEditingController(text: widget.test.readingValue.toString());
    _selectedDate = widget.test.testDate;
  }

  @override
  void dispose() {
    _readingController.dispose();
    super.dispose();
  }

  Future<void> _updateTest() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final result = await ClinicalDataService.updateTest(
        widget.test.id!,
        {
          'dataType': widget.test.type.name,
          'reading': double.parse(_readingController.text),
          'testDate': _selectedDate.toIso8601String(),
        },
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Test updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate refresh needed
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to update test';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }

    // After picking date, show time picker
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String _getUnitForType(DataType type) {
    switch (type) {
      case DataType.bloodPressure:
        return 'mmHg';
      case DataType.respiratoryRate:
        return 'breaths/min';
      case DataType.bloodOxygenLevel:
        return '%';
      case DataType.heartBeatRate:
        return 'bpm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Details'),
        backgroundColor: const Color(0xFF024A59),
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _error,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Patient Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFF024A59),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.patient.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Age: ${widget.patient.age} | ${widget.patient.condition}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Test Details
            const Text(
              'Test Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Test Type
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Test Type'),
              subtitle: Text(widget.test.type.name),
            ),

            // Reading Value
            ListTile(
              leading: const Icon(Icons.monitor_heart),
              title: const Text('Reading'),
              subtitle: _isEditing
                  ? TextField(
                      controller: _readingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter reading value',
                        suffixText: _getUnitForType(widget.test.type),
                      ),
                    )
                  : Text('${widget.test.readingValue} ${_getUnitForType(widget.test.type)}'),
            ),

            // Test Date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Test Date & Time'),
              subtitle: _isEditing
                  ? TextButton(
                      onPressed: _selectDate,
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} '
                        '${_selectedDate.hour}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                      ),
                    )
                  : Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} '
                      '${_selectedDate.hour}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                    ),
            ),

            // Critical Flag
            ListTile(
              leading: Icon(
                Icons.warning,
                color: widget.test.criticalFlag ? Colors.red : Colors.grey,
              ),
              title: const Text('Status'),
              subtitle: Text(
                widget.test.criticalFlag ? 'Critical' : 'Normal',
                style: TextStyle(
                  color: widget.test.criticalFlag ? Colors.red : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isEditing
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF024A59),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            )
          : null,
    );
  }
} 
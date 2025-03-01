import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/clinical_data.dart';

class AddClinicalDataScreen extends StatefulWidget {
  final Patient patient;

  const AddClinicalDataScreen({
    super.key,
    required this.patient,
  });

  @override
  State<AddClinicalDataScreen> createState() => _AddClinicalDataScreenState();
}

class _AddClinicalDataScreenState extends State<AddClinicalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  late DataType _selectedType;
  final TextEditingController _valueController = TextEditingController();
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedType = DataType.bloodPressure;
    _selectedDateTime = DateTime.now();
  }

  String _getUnitForType(DataType type) {
    switch (type) {
      case DataType.bloodPressure:
        return 'mmHg';
      case DataType.heartBeatRate:
        return 'bpm';
      case DataType.bloodOxygenLevel:
        return '%';
      case DataType.respiratoryRate:
        return 'breaths/min';
    }
  }

  String? _validateValue(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    if (_selectedType == DataType.bloodPressure) {
      // Check for blood pressure format (e.g., 120/80)
      if (!RegExp(r'^\d+/\d+$').hasMatch(value)) {
        return 'Enter blood pressure in format: 120/80';
      }
    } else {
      // For other types, ensure it's a number
      if (double.tryParse(value) == null) {
        return 'Please enter a valid number';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Clinical Test'),
        backgroundColor: const Color(0xFF024A59),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Column(
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Test Type Dropdown
              DropdownButtonFormField<DataType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Test Type',
                  border: OutlineInputBorder(),
                ),
                items: DataType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                      _valueController.clear(); // Clear value when type changes
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Value Input
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: 'Value',
                  border: const OutlineInputBorder(),
                  suffixText: _getUnitForType(_selectedType),
                  hintText: _selectedType == DataType.bloodPressure
                      ? 'e.g., 120/80'
                      : 'Enter value',
                ),
                validator: _validateValue,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),

              // Date & Time Picker
              ListTile(
                title: const Text('Date and Time'),
                subtitle: Text(
                  '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} '
                  '${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateTime,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF024A59),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newData = ClinicalData(
                        type: _selectedType,
                        value: _valueController.text,
                        unit: _getUnitForType(_selectedType),
                        dateTime: _selectedDateTime,
                      );
                      widget.patient.clinicalData.add(newData);
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('Save Test Result'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }
}

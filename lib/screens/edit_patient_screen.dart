import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class EditPatientScreen extends StatefulWidget {
  final Patient patient;

  const EditPatientScreen({
    super.key,
    required this.patient,
  });

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactController;
  late DateTime? _selectedDob;
  late String _selectedGender;
  late PatientStatus _selectedStatus;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing patient data
    _nameController = TextEditingController(text: widget.patient.name);
    _addressController = TextEditingController(text: widget.patient.address ?? '');
    _contactController = TextEditingController(text: widget.patient.contactNumber ?? '');
    _selectedDob = widget.patient.dob;
    _selectedGender = widget.patient.gender;
    _selectedStatus = widget.patient.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  Future<void> _updatePatient() async {
    print('Update patient function called');
    
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    if (_selectedDob == null) {
      print('Date of birth not selected');
      setState(() {
        _errorMessage = 'Please select date of birth';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('Getting user ID...');
      final userId = await AuthService.getUserId();
      
      if (!mounted) return;
      
      if (userId == null) {
        print('User ID is null');
        setState(() {
          _isLoading = false;
          _errorMessage = 'User is not logged in. Please login again.';
        });
        return;
      }

      print('Creating updated patient data...');
      // Create updated patient data
      final updatedPatient = Patient(
        id: widget.patient.id,
        userId: userId,
        name: _nameController.text.trim(),
        dob: _selectedDob!,
        gender: _selectedGender,
        address: _addressController.text.trim(),
        contactNumber: _contactController.text.trim(),
        status: _selectedStatus,
      );

      print('Sending updated patient data: ${jsonEncode(updatedPatient.toJson())}');

      // Check API availability with timeout
      print('Checking API availability...');
      final bool isApiAvailable = await ApiConfig.checkApiAvailability().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print('API availability check timed out');
          return false;
        },
      );
      
      if (!mounted) return;
      
      if (!isApiAvailable) {
        print('API is not available');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Server is not available. Please try again later.';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot connect to server. Please check your connection.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      print('API is available, proceeding with patient update...');

      // Update patient with timeout
      final result = await PatientService.updatePatient(
        widget.patient.id!,
        updatedPatient,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('Update request timed out');
          throw Exception('Request timed out. Please try again.');
        },
      );
      
      print('API Response: $result');
      
      if (!mounted) return;
      
      if (result['success']) {
        print('Update successful');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Return to previous screen with the updated patient data
        Navigator.pop(context, result['data']);
      } else {
        print('Update failed: ${result['message']}');
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'] ?? 'Failed to update patient';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error during update: $e');
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      onPopInvoked: (didPop) {
        if (_isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please wait while saving...'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Patient'),
          backgroundColor: const Color(0xFF024A59),
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Image Section
                      Center(
                        child: Stack(
                          children: [
                            const CircleAvatar(
                              radius: 50,
                              backgroundColor: Color(0xFF024A59),
                              child: Icon(Icons.person, size: 50, color: Colors.white),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 18,
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt, size: 18),
                                  onPressed: () {
                                    // Implement image picker
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form Fields
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Patient Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required';
                          }
                          if (value.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date of Birth Field
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _selectedDob == null
                                ? 'Select Date of Birth'
                                : DateFormat('MMM dd, yyyy').format(_selectedDob!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone_outlined),
                          hintText: 'Enter 10 digit number',
                        ),
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        onChanged: (value) {
                          // Remove any non-digit characters
                          final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                          if (digitsOnly != value) {
                            _contactController.text = digitsOnly;
                            _contactController.selection = TextSelection.fromPosition(
                              TextPosition(offset: digitsOnly.length),
                            );
                          }
                        },
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            // Remove any non-digit characters for validation
                            final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                            if (digitsOnly.length != 10) {
                              return 'Phone number must be exactly 10 digits';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Gender *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Male',
                            child: Text('Male'),
                          ),
                          DropdownMenuItem(
                            value: 'Female',
                            child: Text('Female'),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedGender = value;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a gender';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                     

                      // Error message
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _updatePatient,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF024A59),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Saving...'),
                                ],
                              )
                            : const Text('Update Patient'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
} 
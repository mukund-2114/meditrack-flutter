import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/patient.dart';
import 'auth_service.dart';

class PatientService {
  // Alias for getAllPatients
  static Future<Map<String, dynamic>> getPatients() async => getAllPatients();

  // Get all patients
  static Future<Map<String, dynamic>> getAllPatients() async {
    try {
      final token = await AuthService.getUserToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }
      
      print('Fetching patients from: ${ApiConfig.patients}');
      print('Using token: ${token.substring(0, 10)}...');
      
      final response = await http.get(
        Uri.parse(ApiConfig.patients),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body.substring(0, min(100, response.body.length))}...');
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final List<dynamic> patientsJson = responseData ?? [];
        final List<Patient> patients = patientsJson
            .map((json) => Patient.fromJson(json))
            .toList();
            
        print('Parsed ${patients.length} patients');
        
        return {
          'success': true,
          'message': 'Patients retrieved successfully',
          'data': patients
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get patients',
        };
      }
    } catch (e) {
      print('Error fetching patients: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Get critical patients
  static Future<Map<String, dynamic>> getCriticalPatients() async {
    try {
      final token = await AuthService.getUserToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }
      
      print('Fetching critical patients from: ${ApiConfig.criticalPatients}');
      
      final response = await http.get(
        Uri.parse(ApiConfig.criticalPatients),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);

      print('Critical response status: ${response.statusCode}');
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final List<dynamic> patientsJson = responseData ?? [];
        final List<Patient> patients = patientsJson
            .map((json) => Patient.fromJson(json))
            .toList();
            
        print('Parsed ${patients.length} critical patients');
        
        return {
          'success': true,
          'message': 'Critical patients retrieved successfully',
          'data': patients
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get critical patients',
        };
      }
    } catch (e) {
      print('Error fetching critical patients: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Get patient by ID
  static Future<Map<String, dynamic>> getPatientById(String patientId) async {
    try {
      final token = await AuthService.getUserToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }
      
      final response = await http.get(
        Uri.parse('${ApiConfig.patients}/$patientId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final patientJson = responseData['data'];
        final patient = Patient.fromJson(patientJson);
            
        return {
          'success': true,
          'message': 'Patient retrieved successfully',
          'data': patient
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get patient',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Add a new patient
  static Future<Map<String, dynamic>> addPatient(Patient patient) async {
    try {
      final token = await AuthService.getUserToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }
      
      final response = await http.post(
        Uri.parse(ApiConfig.patients),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(patient.toJson()),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        final patientJson = responseData['data'];
        final createdPatient = Patient.fromJson(patientJson);
            
        return {
          'success': true,
          'message': 'Patient added successfully',
          'data': createdPatient
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to add patient',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Update patient
  static Future<Map<String, dynamic>> updatePatient(String patientId, Patient patient) async {
    try {
      final token = await AuthService.getUserToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }
      
      final response = await http.put(
        Uri.parse('${ApiConfig.patients}/$patientId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(patient.toJson()),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final patientJson = responseData['data'];
        final updatedPatient = Patient.fromJson(patientJson);
            
        return {
          'success': true,
          'message': 'Patient updated successfully',
          'data': updatedPatient
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update patient',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Delete patient
  static Future<Map<String, dynamic>> deletePatient(String patientId) async {
    try {
      final token = await AuthService.getUserToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }
      
      final response = await http.delete(
        Uri.parse('${ApiConfig.patients}/$patientId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Patient deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete patient',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}

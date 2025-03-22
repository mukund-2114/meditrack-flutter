import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/clinical_data.dart';
import 'auth_service.dart';

class ClinicalDataService {
  // Get all tests for a patient
  static Future<Map<String, dynamic>> getTestsByPatientId(String patientId) async {
    try {
      final token = await AuthService.getUserToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }
      
      final response = await http.get(
        Uri.parse('${ApiConfig.tests}/$patientId/tests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final List<dynamic> testsJson = responseData['data'] ?? [];
        final List<ClinicalData> tests = testsJson
            .map((json) => ClinicalData.fromJson(json))
            .toList();
            
        return {
          'success': true,
          'message': 'Tests retrieved successfully',
          'data': tests
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get tests',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Get critical tests
  static Future<Map<String, dynamic>> getCriticalTests() async {
    try {
      final token = await AuthService.getUserToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }
      
      final response = await http.get(
        Uri.parse(ApiConfig.criticalTests),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final List<dynamic> testsJson = responseData['data'] ?? [];
        final List<ClinicalData> tests = testsJson
            .map((json) => ClinicalData.fromJson(json))
            .toList();
            
        return {
          'success': true,
          'message': 'Critical tests retrieved successfully',
          'data': tests
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get critical tests',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Get test by ID
  static Future<Map<String, dynamic>> getTestById(String testId) async {
    try {
      final token = await AuthService.getUserToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }
      
      final response = await http.get(
        Uri.parse('${ApiConfig.tests}/$testId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final testJson = responseData['data'];
        final test = ClinicalData.fromJson(testJson);
            
        return {
          'success': true,
          'message': 'Test retrieved successfully',
          'data': test
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get test',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Add a new test
  static Future<Map<String, dynamic>> addTest(String patientId, ClinicalData test) async {
    try {
      final token = await AuthService.getUserToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }
      
      final response = await http.post(
        Uri.parse('${ApiConfig.tests}/$patientId/tests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(test.toJson()),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        final testJson = responseData['data'];
        final createdTest = ClinicalData.fromJson(testJson);
            
        return {
          'success': true,
          'message': 'Test added successfully',
          'data': createdTest
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to add test',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Update test
  static Future<Map<String, dynamic>> updateTest(String testId, ClinicalData test) async {
    try {
      final token = await AuthService.getUserToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }
      
      final response = await http.put(
        Uri.parse('${ApiConfig.tests}/$testId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(test.toJson()),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final testJson = responseData['data'];
        final updatedTest = ClinicalData.fromJson(testJson);
            
        return {
          'success': true,
          'message': 'Test updated successfully',
          'data': updatedTest
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update test',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Delete test
  static Future<Map<String, dynamic>> deleteTest(String testId) async {
    try {
      final token = await AuthService.getUserToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }
      
      final response = await http.delete(
        Uri.parse('${ApiConfig.tests}/$testId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Test deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete test',
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/dashboard_screen.dart';
import '../screens/patient_list_screen.dart';
import '../screens/tests_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/menu_screen.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;

class BottomNavController extends StatefulWidget {
  const BottomNavController({super.key});

  @override
  State<BottomNavController> createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  List<Patient> _patients = [];
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    // Delay the fetch slightly to ensure proper widget initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkApiAndFetchData();
    });
  }

  // Check API availability before fetching data
  Future<void> _checkApiAndFetchData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = '';
    });

    try {
      // First, check if the API is available
      print('Checking API availability...');
      final isAvailable = await ApiConfig.checkApiAvailability();
      
      if (!isAvailable) {
        print('API is not available, sending wake-up request...');
        // Try to wake up the server with a simple GET request
        try {
          await http.get(Uri.parse(ApiConfig.baseUrl)).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('Wake-up request timed out');
              throw Exception('Server wake-up timed out');
            },
          );
          print('Wake-up request sent');
        } catch (e) {
          print('Wake-up request failed: $e');
          // Continue anyway, the server might be waking up
        }
        
        // Wait a bit for the server to wake up
        await Future.delayed(const Duration(seconds: 2));
      }
      
      // Now fetch the data
      await _fetchPatients();
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Failed to connect to server: ${e.toString()}';
      });
      
      _showErrorSnackBar();
    }
  }

  Future<void> _fetchPatients() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final patientProvider = Provider.of<PatientProvider>(context, listen: false);
      await patientProvider.fetchAllPatients(); 
      await patientProvider.fetchCriticalPatients(); 
      
      if (!mounted) return;
      
      final patients = patientProvider.patients;
      
      setState(() {
        _patients = patients;
        _isLoading = false;
        _retryCount = 0; // Reset retry count on success
      });
      
      // If we got no patients but no error occurred, show a message
      if (patients.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No patients found. Add patients to get started.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
      
      _showErrorSnackBar();
    }
  }
  
  void _showErrorSnackBar() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error loading data: $_errorMessage'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            _retryCount++;
            if (_retryCount <= _maxRetries) {
              // Add increasing delay for each retry
              Future.delayed(Duration(seconds: _retryCount), () {
                _checkApiAndFetchData();
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Maximum retry attempts reached. Please try again later.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define screens with the fetched patients
    final List<Widget> screens = [
      _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_errorMessage', 
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _checkApiAndFetchData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF024A59),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : DashboardScreen(
                  patients: _patients,
                  onRefresh: _checkApiAndFetchData,
                ),
      const ProfileScreen(),
      _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? Center(
                  child: ElevatedButton(
                    onPressed: _checkApiAndFetchData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF024A59),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                )
              : TestsScreen(patients: _patients),
      _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? Center(
                  child: ElevatedButton(
                    onPressed: _checkApiAndFetchData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF024A59),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                )
              : MenuScreen(patients: _patients),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF024A59),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: 'Tests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'Menu',
            ),
          ],
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}

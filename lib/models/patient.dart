import 'clinical_data.dart';
import 'package:flutter/material.dart';

enum PatientStatus { stable, moderate, critical }

extension PatientStatusExtension on PatientStatus {
  String get name {
    switch (this) {
      case PatientStatus.stable:
        return 'Stable';
      case PatientStatus.moderate:
        return 'Moderate';
      case PatientStatus.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case PatientStatus.stable:
        return Colors.green;
      case PatientStatus.moderate:
        return Colors.orange;
      case PatientStatus.critical:
        return Colors.red;
    }
  }
}

class Patient {
  final String id;
  final String name;
  final int age;
  final String condition;
  final DateTime lastChecked;
  final PatientStatus status;
  final String? careNotes;
  final List<ClinicalData> clinicalData;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.condition,
    required this.lastChecked,
    required this.status,
    this.careNotes,
  }) : clinicalData = [
          ClinicalData(
            type: DataType.bloodPressure,
            value: '120/80',
            unit: 'mmHg',
            dateTime: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ClinicalData(
            type: DataType.heartBeatRate,
            value: '72',
            unit: 'bpm',
            dateTime: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ClinicalData(
            type: DataType.bloodOxygenLevel,
            value: '98',
            unit: '%',
            dateTime: DateTime.now().subtract(const Duration(hours: 12)),
          ),
          ClinicalData(
            type: DataType.respiratoryRate,
            value: '16',
            unit: 'breaths/min',
            dateTime: DateTime.now().subtract(const Duration(days: 3)),
          ),
          // Add more sample data as needed
        ];
}

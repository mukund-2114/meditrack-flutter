class ClinicalData {
  final DataType type;
  final String value;
  final String unit;
  final DateTime dateTime;

  const ClinicalData({
    required this.type,
    required this.value,
    required this.unit,
    required this.dateTime,
  });
}

enum DataType {
  bloodPressure,
  heartBeatRate,
  bloodOxygenLevel,
  respiratoryRate;

  String get name {
    switch (this) {
      case DataType.bloodPressure:
        return 'Blood Pressure';
      case DataType.heartBeatRate:
        return 'Heart Rate';
      case DataType.bloodOxygenLevel:
        return 'Blood Oxygen';
      case DataType.respiratoryRate:
        return 'Respiratory Rate';
    }
  }

  String get unit {
    switch (this) {
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
}

import '../models/custom_medication.dart';

class Child {
  String name;
  double weight;
  int age;
  List<TemperatureRecord> temperatureLog;
  List<MedicationRecord> medicationLog;
  List<CustomMedication> customMedications;

  Child({
    required this.name,
    required this.weight,
    required this.age,
    List<TemperatureRecord>? temperatureLog,
    List<MedicationRecord>? medicationLog,
    List<CustomMedication>? customMedications,
  }) : temperatureLog = temperatureLog ?? [],
       medicationLog = medicationLog ?? [],
       customMedications = customMedications ?? [];

  // Расчет дозировки парацетамола
  Map<String, double> calculateParacetamolDose() {
    double singleDose;
    double maxDaily;
    
    if (weight < 3) { // до 3 месяцев
      singleDose = (weight * 10).roundToDouble();
      maxDaily = singleDose * 4;
    } else if (weight < 5) { // 3 месяца - 1 год
      singleDose = 60;
      maxDaily = 240;
    } else if (weight < 10) { // 1-5 лет
      singleDose = 120;
      maxDaily = 480;
    } else if (weight < 30) { // 6-12 лет
      singleDose = 250;
      maxDaily = 1000;
    } else { // взрослые и подростки >60кг
      singleDose = 500;
      maxDaily = 4000;
    }
    
    return {'single': singleDose, 'maxDaily': maxDaily};
  }

  // Расчет дозировки ибупрофена
  Map<String, double> calculateIbuprofenDose() {
    double singleDose;
    double maxDaily;
    int intervalHours = 8; // стандартный интервал
    
    // Определяем возрастную группу
    if (age < 72) { // до 6 лет (меньше 72 месяцев)
      singleDose = (weight * 10).roundToDouble(); // 10 мг/кг
      maxDaily = (weight * 30).roundToDouble(); // макс 30 мг/кг
    } else if (age >= 72 && age <= 144) { // 6-12 лет (72-144 месяца)
      singleDose = 200;
      maxDaily = 800;
    } else if (age >= 145 && age <= 204) { // 12-17 лет (145-204 месяца)
      singleDose = 400;
      maxDaily = 1000;
    } else { // взрослые (18+ лет)
      singleDose = 400;
      maxDaily = 1200;
    }
    
    return {'single': singleDose, 'maxDaily': maxDaily, 'interval': intervalHours.toDouble()};
  }

  // Подсчет суточной дозировки
  double getDailyDose(String medType) {
    DateTime now = DateTime.now();
    DateTime dayStart = DateTime(now.year, now.month, now.day);
    
    double totalDose = 0;
    for (var med in medicationLog) {
      if (med.type == medType && med.time.isAfter(dayStart)) {
        totalDose += med.dose;
      }
    }
    return totalDose;
  }

  // Проверка продолжительности лечения
  bool shouldWarnAboutDuration(String medType) {
    DateTime now = DateTime.now();
    int maxDays = medType == 'paracetamol' ? 3 : 3; // оба препарата - 3 дня
    
    DateTime cutoffDate = now.subtract(Duration(days: maxDays));
    
    // Проверяем, был ли прием лекарства раньше максимального срока
    for (var med in medicationLog) {
      if (med.type == medType && med.time.isBefore(cutoffDate)) {
        return true;
      }
    }
    return false;
  }

  // Проверка возможности приема лекарства
  Map<String, dynamic> canTakeMedication(String medType) {
    DateTime now = DateTime.now();
    
    // Проверка интервала
    for (var med in medicationLog.reversed) {
      if (med.type == medType) {
        Duration timeDiff = now.difference(med.time);
        int minInterval;
        if (medType == 'paracetamol') {
          minInterval = 4; // парацетамол - 4 часа
        } else {
          // ибупрофен - зависит от веса
          Map<String, double> ibuDose = calculateIbuprofenDose();
          minInterval = ibuDose['interval']!.toInt();
        }
        
        if (timeDiff.inHours < minInterval) {
          double waitHours = minInterval - (timeDiff.inMinutes / 60.0);
          return {'canTake': false, 'waitHours': waitHours, 'reason': 'interval'};
        }
        break;
      }
    }
    
    // Проверка суточной дозировки
    double currentDailyDose = getDailyDose(medType);
    Map<String, double> maxDoses = medType == 'paracetamol' 
        ? calculateParacetamolDose() 
        : calculateIbuprofenDose();
    
    Map<String, double> singleDoses = medType == 'paracetamol' 
        ? calculateParacetamolDose() 
        : calculateIbuprofenDose();
    
    if (currentDailyDose + singleDoses['single']! > maxDoses['maxDaily']!) {
      return {
        'canTake': false, 
        'waitHours': 0.0, 
        'reason': 'dailyLimit',
        'currentDose': currentDailyDose,
        'maxDose': maxDoses['maxDaily']
      };
    }
    
    // Проверка продолжительности лечения
    bool needsDurationWarning = shouldWarnAboutDuration(medType);
    
    return {
      'canTake': true, 
      'waitHours': 0.0,
      'durationWarning': needsDurationWarning
    };
  }

  // Конвертация в JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'weight': weight,
      'age': age,
      'temperatureLog': temperatureLog.map((t) => t.toJson()).toList(),
      'medicationLog': medicationLog.map((m) => m.toJson()).toList(),
      'customMedications': customMedications.map((c) => c.toJson()).toList(),
    };
  }

  // Создание из JSON
  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      name: json['name'],
      weight: json['weight'].toDouble(),
      age: json['age'] ?? 0,
      temperatureLog: (json['temperatureLog'] as List?)
          ?.map((t) => TemperatureRecord.fromJson(t))
          .toList() ?? [],
      medicationLog: (json['medicationLog'] as List?)
          ?.map((m) => MedicationRecord.fromJson(m))
          .toList() ?? [],
      customMedications: (json['customMedications'] as List?)
          ?.map((c) => CustomMedication.fromJson(c))
          .toList() ?? [],
    );
  }
}

class TemperatureRecord {
  DateTime time;
  double value;

  TemperatureRecord({required this.time, required this.value});

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'value': value,
    };
  }

  factory TemperatureRecord.fromJson(Map<String, dynamic> json) {
    return TemperatureRecord(
      time: DateTime.parse(json['time']),
      value: json['value'].toDouble(),
    );
  }
}

class MedicationRecord {
  DateTime time;
  String type;
  double dose;

  MedicationRecord({
    required this.time,
    required this.type,
    required this.dose,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'type': type,
      'dose': dose,
    };
  }

  factory MedicationRecord.fromJson(Map<String, dynamic> json) {
    return MedicationRecord(
      time: DateTime.parse(json['time']),
      type: json['type'],
      dose: json['dose'].toDouble(),
    );
  }
}
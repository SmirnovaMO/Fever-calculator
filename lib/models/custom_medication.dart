import 'package:flutter/material.dart';

class CustomMedication {
  String name;
  bool hasReminders;
  int dailyDoses;
  List<TimeOfDay> times;
  int durationDays;
  DateTime startDate;
  
  CustomMedication({
    required this.name,
    this.hasReminders = false,
    this.dailyDoses = 1,
    List<TimeOfDay>? times,
    this.durationDays = 1,
    DateTime? startDate,
  }) : times = times ?? [],
       startDate = startDate ?? DateTime.now();

  int get remainingDays {
    final now = DateTime.now();
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final nowDateOnly = DateTime(now.year, now.month, now.day);
    final daysPassed = nowDateOnly.difference(startDateOnly).inDays;
    final remaining = durationDays - daysPassed;
    return remaining > 0 ? remaining : 0;
  }

  bool get isActive => remainingDays > 0;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hasReminders': hasReminders,
      'dailyDoses': dailyDoses,
      'times': times.map((t) => {'hour': t.hour, 'minute': t.minute}).toList(),
      'durationDays': durationDays,
      'startDate': startDate.toIso8601String(),
    };
  }

  factory CustomMedication.fromJson(Map<String, dynamic> json) {
    return CustomMedication(
      name: json['name'],
      hasReminders: json['hasReminders'] ?? false,
      dailyDoses: json['dailyDoses'] ?? 1,
      times: (json['times'] as List?)
          ?.map((t) => TimeOfDay(hour: t['hour'], minute: t['minute']))
          .toList() ?? [],
      durationDays: json['durationDays'] ?? 1,
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
    );
  }
}
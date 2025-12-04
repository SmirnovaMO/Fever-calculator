import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/child.dart';
import '../models/custom_medication.dart';
import '../widgets/temperature_chart.dart';
import '../notification_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:io';

class ChildScreen extends StatefulWidget {
  final Child child;

  ChildScreen({required this.child});

  @override
  _ChildScreenState createState() => _ChildScreenState();
}

class _ChildScreenState extends State<ChildScreen> {
  final TextEditingController tempController = TextEditingController();
  final TextEditingController paracetamolDoseController = TextEditingController();
  final TextEditingController ibuprofenDoseController = TextEditingController();
  
  String? selectedParacetamolForm;
  String? selectedIbuprofenForm;
  
  // Пользовательские лекарства
  final TextEditingController customMedNameController = TextEditingController();
  bool wantsReminders = false;
  int dailyDoses = 1;
  List<TimeOfDay> selectedTimes = [TimeOfDay(hour: 8, minute: 0)];
  int durationDays = 1;
  bool showCustomMedForm = false;
  
  final Map<String, Map<String, dynamic>> medicationForms = {
    'paracetamol': {
      // Пока пусто, добавим позже
    },
    'ibuprofen': {
      'Ибупрофен суспензия 100мг/5мл': {
        'concentration': 20.0, // мг/мл
        'unit': 'мл',
        'doses': {
          3: {'recommended': 0.75, 'max': 1.5},
          4: {'recommended': 1.0, 'max': 2.0},
          5: {'recommended': 1.25, 'max': 2.5},
          6: {'recommended': 1.5, 'max': 3.0},
          7: {'recommended': 1.75, 'max': 3.5},
          8: {'recommended': 2.0, 'max': 4.0},
          9: {'recommended': 2.25, 'max': 4.5},
          10: {'recommended': 2.5, 'max': 5.0},
          11: {'recommended': 2.75, 'max': 5.5},
          12: {'recommended': 6.0, 'max': 12.0},
          13: {'recommended': 6.5, 'max': 13.0},
          14: {'recommended': 7.0, 'max': 14.0},
          15: {'recommended': 7.5, 'max': 15.0},
          16: {'recommended': 8.0, 'max': 16.0},
          17: {'recommended': 8.5, 'max': 17.0},
          18: {'recommended': 9.0, 'max': 18.0},
          19: {'recommended': 9.5, 'max': 19.0},
          20: {'recommended': 10.0, 'max': 20.0},
          21: {'recommended': 10.0, 'max': 10.5},
          22: {'recommended': 10.0, 'max': 11.0},
          23: {'recommended': 10.0, 'max': 11.5},
          24: {'recommended': 10.0, 'max': 12.0},
          25: {'recommended': 10.0, 'max': 12.5},
          26: {'recommended': 10.0, 'max': 13.0},
          27: {'recommended': 10.0, 'max': 13.5},
          28: {'recommended': 10.0, 'max': 14.0},
          29: {'recommended': 10.0, 'max': 14.5},
          30: {'recommended': 10.0, 'max': 15.0},
          31: {'recommended': 10.0, 'max': 15.5},
          32: {'recommended': 10.0, 'max': 16.0},
          33: {'recommended': 10.0, 'max': 16.5},
          34: {'recommended': 10.0, 'max': 17.0},
          35: {'recommended': 10.0, 'max': 17.5},
          36: {'recommended': 10.0, 'max': 18.0},
          37: {'recommended': 10.0, 'max': 18.5},
          40: {'recommended': 10.0, 'max': 20.0},
        }
      },
      'Ибупрофен Форте 200мг/5мл': {
        'concentration': 40.0, // мг/мл
        'unit': 'мл',
        'doses': {
          3: {'recommended': 0.37, 'max': 0.75},
          4: {'recommended': 0.5, 'max': 1.0},
          5: {'recommended': 0.6, 'max': 1.25},
          6: {'recommended': 0.7, 'max': 1.5},
          7: {'recommended': 0.9, 'max': 1.75},
          8: {'recommended': 1.0, 'max': 2.0},
          9: {'recommended': 1.2, 'max': 2.25},
          10: {'recommended': 1.25, 'max': 2.5},
          11: {'recommended': 1.4, 'max': 2.75},
          12: {'recommended': 3.0, 'max': 6.0},
          13: {'recommended': 3.25, 'max': 6.5},
          14: {'recommended': 3.5, 'max': 7.0},
          15: {'recommended': 3.75, 'max': 7.5},
          16: {'recommended': 4.0, 'max': 8.0},
          17: {'recommended': 4.25, 'max': 8.5},
          18: {'recommended': 4.5, 'max': 9.0},
          19: {'recommended': 4.75, 'max': 9.5},
          20: {'recommended': 5.0, 'max': 10.0},
          21: {'recommended': 5.0, 'max': 5.25},
          22: {'recommended': 5.0, 'max': 5.5},
          23: {'recommended': 5.0, 'max': 5.75},
          24: {'recommended': 5.0, 'max': 6.0},
          25: {'recommended': 5.0, 'max': 6.25},
          26: {'recommended': 5.0, 'max': 6.5},
          27: {'recommended': 5.0, 'max': 6.75},
          28: {'recommended': 5.0, 'max': 7.0},
          29: {'recommended': 5.0, 'max': 7.25},
          30: {'recommended': 5.0, 'max': 7.5},
          31: {'recommended': 5.0, 'max': 7.75},
          32: {'recommended': 5.0, 'max': 8.0},
          33: {'recommended': 5.0, 'max': 8.25},
          34: {'recommended': 5.0, 'max': 8.5},
          35: {'recommended': 5.0, 'max': 8.75},
          36: {'recommended': 5.0, 'max': 9.0},
          37: {'recommended': 5.0, 'max': 9.25},
          40: {'recommended': 5.0, 'max': 10.0},
        }
      },
      'Ибупрофен свечи 60мг': {
        'concentration': 60.0, // мг на свечу
        'unit': 'свечи',
        'doses': {
          3: {'recommended': 0.5, 'max': 1.0},
          4: {'recommended': 0.5, 'max': 1.0},
          5: {'recommended': 1.0, 'max': 1.0},
          6: {'recommended': 1.0, 'max': 1.0},
          7: {'recommended': 1.0, 'max': 1.0},
          8: {'recommended': 1.5, 'max': 1.5},
          9: {'recommended': 1.5, 'max': 1.5},
          10: {'recommended': 1.5, 'max': 1.5},
          11: {'recommended': 2.0, 'max': 2.0},
          12: {'recommended': 2.0, 'max': 2.0},
          13: {'recommended': 2.0, 'max': 2.0},
        }
      },
      'Ибупрофен свечи 125мг': {
        'concentration': 125.0, // мг на свечу
        'unit': 'свечи',
        'doses': {
          7: {'recommended': 0.5, 'max': 0.5},
          8: {'recommended': 0.5, 'max': 0.5},
          9: {'recommended': 0.5, 'max': 0.5},
          10: {'recommended': 0.5, 'max': 0.5},
          11: {'recommended': 0.5, 'max': 0.5},
          12: {'recommended': 1.0, 'max': 1.0},
          13: {'recommended': 1.0, 'max': 1.0},
          14: {'recommended': 1.0, 'max': 1.0},
          15: {'recommended': 1.0, 'max': 1.0},
          16: {'recommended': 1.0, 'max': 1.0},
          17: {'recommended': 1.0, 'max': 1.0},
          18: {'recommended': 1.0, 'max': 1.0},
          19: {'recommended': 1.5, 'max': 1.5},
          20: {'recommended': 1.5, 'max': 1.5},
          21: {'recommended': 1.5, 'max': 1.5},
          22: {'recommended': 1.5, 'max': 1.5},
          23: {'recommended': 1.5, 'max': 1.5},
          24: {'recommended': 1.5, 'max': 1.5},
          25: {'recommended': 2.0, 'max': 2.0},
          26: {'recommended': 2.0, 'max': 2.0},
          27: {'recommended': 2.0, 'max': 2.0},
          28: {'recommended': 2.0, 'max': 2.0},
          29: {'recommended': 2.0, 'max': 2.0},
        }
      },
      'Ибупрофен таблетки 200мг': {
        'concentration': 200.0, // мг на таблетку
        'unit': 'табл.',
        'doses': {
          10: {'recommended': 0.5, 'max': 0.5},
          11: {'recommended': 0.5, 'max': 0.5},
          12: {'recommended': 0.5, 'max': 0.5},
          13: {'recommended': 0.5, 'max': 0.5},
          14: {'recommended': 0.5, 'max': 0.5},
          15: {'recommended': 0.5, 'max': 0.5},
          16: {'recommended': 0.5, 'max': 0.5},
          17: {'recommended': 0.5, 'max': 0.5},
          18: {'recommended': 0.5, 'max': 0.5},
          19: {'recommended': 0.5, 'max': 0.5},
          20: {'recommended': 1.0, 'max': 1.0},
          21: {'recommended': 1.0, 'max': 1.0},
          22: {'recommended': 1.0, 'max': 1.0},
          23: {'recommended': 1.0, 'max': 1.0},
          24: {'recommended': 1.0, 'max': 1.0},
          25: {'recommended': 1.0, 'max': 1.0},
          26: {'recommended': 1.0, 'max': 1.0},
          27: {'recommended': 1.0, 'max': 1.0},
          28: {'recommended': 1.0, 'max': 1.0},
          29: {'recommended': 1.0, 'max': 1.0},
          30: {'recommended': 1.0, 'max': 1.5},
          31: {'recommended': 1.0, 'max': 1.5},
          32: {'recommended': 1.0, 'max': 1.5},
          33: {'recommended': 1.0, 'max': 1.5},
          34: {'recommended': 1.0, 'max': 1.5},
          35: {'recommended': 1.0, 'max': 1.5},
          36: {'recommended': 1.0, 'max': 1.5},
          37: {'recommended': 1.0, 'max': 1.5},
          40: {'recommended': 1.0, 'max': 2.0},
        }
      },
    },
  };

  void addTemperature() {
    final String tempText = tempController.text.trim().replaceAll(',', '.');
    final double? temp = double.tryParse(tempText);
    
    if (temp == null || temp < 26 || temp > 43) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка'),
          content: Text('Температура должна быть от 26 до 43°C'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Проверка температуры для детей до года
    if (widget.child.age < 12) {
      String title = '';
      String message = '';
      Color titleColor = Colors.black;
      
      if (temp < 32) {
        title = '⚠️ ОПАСНО!';
        titleColor = Colors.red;
        message = 'Слишком низкая температура! Вызывайте Скорую помощь';
      } else if (temp >= 32 && temp < 35.5) {
        title = '⚠️ ВНИМАНИЕ!';
        titleColor = Colors.orange;
        message = 'Вероятно, ребёнок замёрз. Попытайтесь согреть. Если опустится ещё на 0,5 градуса или если есть подозрение на передозировку сосудосуживающих капель (от насморка) - вызывайте Скорую помощь.';
      } else if (temp >= 35.5 && temp < 37.0) {
        title = '✅ Норма';
        titleColor = Colors.green;
        message = 'Температура в норме, можно ничего не предпринимать.';
      } else if (temp >= 37.0 && temp < 37.5) {
        title = '📝 Наблюдение';
        titleColor = Colors.blue;
        message = 'Вероятно, вариант нормы. Разденьте ребёнка, продолжайте наблюдение.';
      } else if (temp >= 37.5 && temp < 38.0) {
        title = '🔥 Умеренное повышение';
        titleColor = Colors.orange;
        message = 'Умеренное повышение температуры. Разденьте ребёнка до футболки, снимите подгузник, повторите измерение через 5-10 минут.';
      } else if (temp >= 38.0 && temp < 40.0) {
        title = '🔥 Температура повышена!';
        titleColor = Colors.red;
        message = 'Температура повышена! Разденьте ребёнка до футболки и снимите подгузник. Дайте жаропонижающий препарат. Если озноба нет (тело ребёнка красное и горячее), этого достаточно, продолжайте наблюдение. Если озноб есть (холодные руки и ноги, ребёнка трясёт как от холода), то тело ребёнка всё равно должно быть раскрыто, но холодные конечности следует согревать: можно одеть шерстяные носки. При выраженном ознобе лучше положить к конечностям грелки. Не стоит бояться «белой лихорадки». Это не признак тяжести состояния ребёнка.';
      } else if (temp >= 40.0 && temp < 41.0) {
        title = '⚠️ ЗНАЧИТЕЛЬНО ПОВЫШЕНА!';
        titleColor = Colors.red;
        message = 'Температура значительно повышена! Разденьте ребёнка до футболки, снимите подгузник. Дайте жаропонижающий препарат. Если тело ребёнка красное и горячее, можно ускорить снижение температуры обтиранием тёплой водой (39-40 градусов), без водки и уксуса. Мочим всё тело, при высыхании - повторяем. Обязательно свяжитесь с врачом и обсудите необходимость госпитализации.';
      } else if (temp >= 41.0) {
        title = '🆘 ОПАСНО ДЛЯ ЖИЗНИ!!!';
        titleColor = Colors.red;
        message = 'Опасное для жизни повышение температуры!!! Срочно вызывайте скорую помощь!!! Пока едет скорая, разденьте ребёнка, снимите подгузник. На расстоянии 5 см около головы ребёнка положите пузырь со льдом. Дайте жаропонижающий препарат, если ребёнок в сознании. Как только конечности согреты, тело ребёнка красное и горячее, можно ускорить снижение температуры обтиранием: тёплой водой (39-40 градусов), без водки и уксуса. Мочим всё тело, при высыхании - повторяем.';
      }
      
      if (title.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.bold)),
            content: Text(message, style: TextStyle(fontSize: 14)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _recordTemperature(temp);
                },
                child: Text('Понятно, записать'),
              ),
            ],
          ),
        );
        return;
      }
    } else if (widget.child.age >= 12 && widget.child.age <= 60) {
      // Проверка температуры для детей от 1 до 5 лет
      String title = '';
      String message = '';
      Color titleColor = Colors.black;
      
      if (temp < 35) {
        title = '⚠️ ОПАСНО!';
        titleColor = Colors.red;
        message = 'Слишком низкая температура! Вызывайте Скорую помощь';
      } else if (temp >= 35 && temp < 35.5) {
        title = '⚠️ ВНИМАНИЕ!';
        titleColor = Colors.orange;
        message = 'Вероятно, ребёнок замёрз. Попытайтесь согреть. Если опустится ещё на 0,5 градуса или если есть подозрение на передозировку сосудосуживающих капель (от насморка) - вызывайте Скорую помощь.';
      } else if (temp >= 35.5 && temp <= 37.0) {
        title = '✅ Норма';
        titleColor = Colors.green;
        message = 'Температура в норме, можно ничего не предпринимать.';
      } else if (temp >= 37.1 && temp <= 38.4) {
        title = '📝 Умеренное повышение';
        titleColor = Colors.blue;
        message = 'Умеренное повышение температуры. При удовлетворительном самочувствии, ничего предпринимать не нужно. Продолжайте наблюдение.';
      } else if (temp >= 38.5 && temp < 40.0) {
        title = '🔥 Температура повышена!';
        titleColor = Colors.red;
        message = 'Температура повышена! Разденьте ребёнка до футболки и снимите подгузник (если используется). Дайте жаропонижающий препарат, если ребёнок испытывает дискомфорт. Если озноба нет (тело ребёнка красное и горячее), этого достаточно, продолжайте наблюдение. Если озноб есть (холодные руки и ноги, ребёнка трясёт как от холода), то тело ребёнка всё равно должно быть раскрыто, но холодные конечности следует согревать: можно одеть шерстяные носки. При выраженном ознобе лучше положить к конечностям грелки. Не стоит бояться «белой лихорадки». Это не признак тяжести состояния ребёнка. Озноб говорит о том, что прямо сейчас идёт подъём температуры.';
      } else if (temp >= 40.0 && temp < 41.0) {
        title = '⚠️ ЗНАЧИТЕЛЬНО ПОВЫШЕНА!';
        titleColor = Colors.red;
        message = 'Температура значительно повышена! Разденьте ребёнка до футболки, снимите подгузник (если используется). Дайте жаропонижающий препарат. Если тело ребёнка красное и горячее, можно ускорить снижение температуры обтиранием тёплой водой (39-40 градусов), без водки и уксуса. Мочим всё тело, при высыхании - повторяем. Обязательно свяжитесь с врачом и обсудите необходимость госпитализации.';
      } else if (temp >= 41.0) {
        title = '🆘 ОПАСНО ДЛЯ ЖИЗНИ!!!';
        titleColor = Colors.red;
        message = 'Опасное для жизни повышение температуры!!! Срочно вызывайте скорую помощь!!! Пока едет скорая, разденьте ребёнка, снимите подгузник (если используется). На расстоянии 5 см около головы ребёнка положите пузырь со льдом. Дайте жаропонижающий препарат, если ребёнок в сознании. Как только конечности согреты, тело ребёнка красное и горячее, можно ускорить снижение температуры обтиранием: тёплой водой (39-40 градусов), без водки и уксуса. Мочим всё тело, при высыхании - повторяем.';
      }
      
      if (title.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.bold)),
            content: Text(message, style: TextStyle(fontSize: 14)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _recordTemperature(temp);
                },
                child: Text('Понятно, записать'),
              ),
            ],
          ),
        );
        return;
      }
    } else if (widget.child.age >= 61 && widget.child.age <= 204) {
      // Проверка температуры для детей от 6 до 17 лет
      String title = '';
      String message = '';
      Color titleColor = Colors.black;
      
      if (temp < 32) {
        title = '⚠️ ОПАСНО!';
        titleColor = Colors.red;
        message = 'Слишком низкая температура! Вызывайте Скорую помощь';
      } else if (temp >= 32 && temp < 35.5) {
        title = '⚠️ ВНИМАНИЕ!';
        titleColor = Colors.orange;
        message = 'Вероятно, ребёнок замёрз. Попытайтесь согреть. Если опустится ещё на 0,5 градуса или если есть подозрение на передозировку сосудосуживающих капель (от насморка) - вызывайте Скорую помощь.';
      } else if (temp >= 35.5 && temp <= 37.0) {
        title = '✅ Норма';
        titleColor = Colors.green;
        message = 'Температура в норме, можно ничего не предпринимать.';
      } else if (temp >= 37.1 && temp <= 38.4) {
        title = '📝 Умеренное повышение';
        titleColor = Colors.blue;
        message = 'Умеренное повышение температуры. При удовлетворительном самочувствии, ничего предпринимать не нужно. Продолжайте наблюдение.';
      } else if (temp >= 38.5 && temp < 40.0) {
        title = '🔥 Температура повышена!';
        titleColor = Colors.red;
        message = 'Температура повышена! Дайте жаропонижающий препарат, если ребёнок испытывает дискомфорт. Если озноба нет (тело ребёнка красное и горячее), этого достаточно, продолжайте наблюдение. Если озноб есть (холодные руки и ноги, ребёнка трясёт как от холода), то тело ребёнка всё равно должно быть раскрыто, но холодные конечности следует согревать: можно одеть шерстяные носки. При выраженном ознобе лучше положить к конечностям грелки. Не стоит бояться «белой лихорадки». Это не признак тяжести состояния ребёнка. Озноб говорит о том, что прямо сейчас идёт подъём температуры.';
      } else if (temp >= 40.0 && temp < 41.0) {
        title = '⚠️ ЗНАЧИТЕЛЬНО ПОВЫШЕНА!';
        titleColor = Colors.red;
        message = 'Температура значительно повышена! Разденьте ребёнка. Дайте жаропонижающий препарат. Если тело ребёнка красное и горячее, можно ускорить снижение температуры обтиранием тёплой водой (39-40 градусов), без водки и уксуса. Мочим всё тело, при высыхании - повторяем. Обязательно свяжитесь с врачом и обсудите необходимость госпитализации.';
      } else if (temp >= 41.0) {
        title = '🆘 ОПАСНО ДЛЯ ЖИЗНИ!!!';
        titleColor = Colors.red;
        message = 'Опасное для жизни повышение температуры!!! Срочно вызывайте скорую помощь!!! Пока едет скорая, разденьте ребёнка. На расстоянии 5 см около головы положите пузырь со льдом. Дайте жаропонижающий препарат, если ребёнок в сознании. Как только конечности согреты, тело ребёнка красное и горячее, можно ускорить снижение температуры обтиранием: тёплой водой (39-40 градусов), без водки и уксуса. Мочим всё тело, при высыхании - повторяем.';
      }
      
      if (title.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.bold)),
            content: Text(message, style: TextStyle(fontSize: 14)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _recordTemperature(temp);
                },
                child: Text('Понятно, записать'),
              ),
            ],
          ),
        );
        return;
      }
    } else {
      // Предупреждение о критических значениях для детей старше 17 лет
      if (temp < 32 || temp > 41) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('⚠️ ВНИМАНИЕ!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            content: Text(
              'Введенное значение температуры может быть признаком жизнеугрожающего состояния!\n\nТребуется ЭКСТРЕННЫЙ вызов врача!',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _recordTemperature(temp);
                },
                child: Text('Понятно, записать температуру'),
              ),
            ],
          ),
        );
        return;
      }
    }

    // Проверка интервала после приема лекарства
    if (widget.child.medicationLog.isNotEmpty) {
      final lastMedication = widget.child.medicationLog.last;
      final timeDiff = DateTime.now().difference(lastMedication.time);
      
      if (timeDiff.inMinutes < 90) {
        final remainingMinutes = 90 - timeDiff.inMinutes;
        final hours = remainingMinutes ~/ 60;
        final minutes = remainingMinutes % 60;
        
        String timeText = '';
        if (hours > 0) {
          timeText = '$hours час';
          if (hours > 1 && hours < 5) timeText += 'а';
          else if (hours >= 5) timeText += 'ов';
          if (minutes > 0) {
            timeText += ' $minutes минут';
            if (minutes == 1 || (minutes > 20 && minutes % 10 == 1)) timeText += 'а';
            else if ((minutes >= 2 && minutes <= 4) || (minutes > 20 && minutes % 10 >= 2 && minutes % 10 <= 4)) timeText += 'ы';
          }
        } else {
          timeText = '$minutes минут';
          if (minutes == 1 || (minutes > 20 && minutes % 10 == 1)) timeText += 'а';
          else if ((minutes >= 2 && minutes <= 4) || (minutes > 20 && minutes % 10 >= 2 && minutes % 10 <= 4)) timeText += 'ы';
        }
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Информация'),
            content: Text('Для оценки терапевтического эффекта должно пройти 1,5 часа после приема лекарства. Ожидаемое значение: через $timeText температура должна снизиться на 0,5 градуса.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Понятно'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _recordTemperature(temp);
                },
                child: Text('Всё равно записать'),
              ),
            ],
          ),
        );
        return;
      }
    }

    _recordTemperature(temp);
  }

  void _recordTemperature(double temp) {

    setState(() {
      widget.child.temperatureLog.add(
        TemperatureRecord(time: DateTime.now(), value: temp),
      );
    });
    
    tempController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Температура ${temp}°C записана'),
        backgroundColor: Color(0xFF4A90A4),
      ),
    );
  }

  void giveMedication(String medType, double dose) {
    final result = widget.child.canTakeMedication(medType);
    
    if (result['canTake']) {
      // Проверяем предупреждение о продолжительности
      if (result['durationWarning'] == true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('⚠️ Превышена продолжительность лечения!', 
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            content: Text('Препарат принимается более 3 дней.\n\nТребуется консультация врача!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _giveMedicationConfirmed(medType, dose);
                },
                child: Text('Понятно, дать лекарство'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              ),
            ],
          ),
        );
      } else {
        _giveMedicationConfirmed(medType, dose);
      }
    } else {
      String title = 'Внимание';
      String message = '';
      
      if (result['reason'] == 'interval') {
        final waitHours = result['waitHours'];
        final hours = waitHours.floor();
        final minutes = ((waitHours - hours) * 60).round();
        
        String timeText = '';
        if (hours > 0) {
          timeText += '$hours ${_getHoursWord(hours)}';
          if (minutes > 0) {
            timeText += ' $minutes ${_getMinutesWord(minutes)}';
          }
        } else {
          timeText = '$minutes ${_getMinutesWord(minutes)}';
        }
        
        message = 'Нужно подождать еще $timeText до следующего приема';
      } else if (result['reason'] == 'dailyLimit') {
        title = '⚠️ Превышение суточной дозы!';
        final medName = medType == 'paracetamol' ? 'парацетамола' : 'ибупрофена';
        final currentDose = result['currentDose'];
        final maxDose = result['maxDose'];
        message = 'Сегодня уже дано: ${currentDose}мг $medName\n'
                 'Максимум в сутки: ${maxDose}мг\n\n'
                 'Дополнительный прием может быть опасен!';
      }
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title, style: TextStyle(
            color: result['reason'] == 'dailyLimit' ? Colors.red : null,
            fontWeight: FontWeight.bold,
          )),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _giveMedicationConfirmed(String medType, double dose) {
    setState(() {
      widget.child.medicationLog.add(
        MedicationRecord(
          time: DateTime.now(),
          type: medType,
          dose: dose,
        ),
      );
    });
    
    final medName = medType == 'paracetamol' ? 'Парацетамол' : 'Ибупрофен';
    final timeStr = DateFormat('HH:mm').format(DateTime.now());
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$medName ${dose}мг дан в $timeStr'),
        backgroundColor: Color(0xFF4A90A4),
      ),
    );
  }

  void editChild() {
    final nameController = TextEditingController(text: widget.child.name);
    final weightController = TextEditingController(text: widget.child.weight.toString());
    final ageController = TextEditingController(text: widget.child.age.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Редактировать данные'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Имя'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: 'Возраст (месяцев)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              controller: weightController,
              decoration: InputDecoration(labelText: 'Вес (кг)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final weightText = weightController.text.trim().replaceAll(',', '.');
              final ageText = ageController.text.trim();
              final weight = double.tryParse(weightText);
              final age = int.tryParse(ageText);
              
              if (name.isNotEmpty && weight != null && weight > 0 && age != null && age >= 0) {
                setState(() {
                  widget.child.name = name;
                  widget.child.weight = weight;
                  widget.child.age = age;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Данные обновлены!'),
                    backgroundColor: Color(0xFF4A90A4),
                  ),
                );
              }
            },
            child: Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  String _getHoursWord(int hours) {
    if (hours % 10 == 1 && hours % 100 != 11) {
      return 'час';
    } else if ([2, 3, 4].contains(hours % 10) && ![12, 13, 14].contains(hours % 100)) {
      return 'часа';
    } else {
      return 'часов';
    }
  }

  String _getMinutesWord(int minutes) {
    if (minutes % 10 == 1 && minutes % 100 != 11) {
      return 'минута';
    } else if ([2, 3, 4].contains(minutes % 10) && ![12, 13, 14].contains(minutes % 100)) {
      return 'минуты';
    } else {
      return 'минут';
    }
  }

  @override
  Widget build(BuildContext context) {
    final paraDose = widget.child.calculateParacetamolDose();
    final ibuDose = widget.child.calculateIbuprofenDose();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.child.name),
            Spacer(),
            IconButton(
              icon: Icon(Icons.picture_as_pdf),
              onPressed: _generateReport,
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: editChild,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Информация о ребенке
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.child_care, size: 32, color: Color(0xFF4A90A4)),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.child.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F4F4F),
                          ),
                        ),
                        Text(
                          'Вес: ${widget.child.weight} кг',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2F4F4F),
                          ),
                        ),
                        Text(
                          'Возраст: ${widget.child.age < 12 ? "${widget.child.age} мес" : "${(widget.child.age / 12).floor()} лет"}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2F4F4F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // График температуры
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'График температуры',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F4F4F),
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      height: 200,
                      child: TemperatureChart(child: widget.child),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Запись температуры
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Записать температуру',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F4F4F),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tempController,
                            decoration: InputDecoration(
                              labelText: 'Температура °C',
                              prefixIcon: Icon(Icons.thermostat),
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: addTemperature,
                          child: Text('📝'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Лекарства
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Жаропонижающие',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F4F4F),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Парацетамол
                    _buildMedicationSection('paracetamol', Colors.orange, '🔶 Парацетамол', paraDose),

                    SizedBox(height: 12),

                    // Ибупрофен
                    _buildMedicationSection('ibuprofen', Colors.blue, '🔵 Ибупрофен', ibuDose),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Пользовательские лекарства
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Пользовательские лекарства',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F4F4F),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildCustomMedicationSection(),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // История
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'История наблюдений',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F4F4F),
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildHistory(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    List<Map<String, dynamic>> allRecords = [];

    // Добавляем температуру
    for (var temp in widget.child.temperatureLog) {
      allRecords.add({
        'time': temp.time,
        'text': '🌡️ ${DateFormat('dd.MM HH:mm').format(temp.time)} - Температура: ${temp.value}°C',
        'type': 'temperature',
      });
    }

    // Добавляем лекарства
    for (var med in widget.child.medicationLog) {
      String medName;
      String icon;
      String doseText;
      
      if (med.type == 'paracetamol') {
        medName = 'Парацетамол';
        icon = '🔶';
        doseText = ': ${med.dose}мг';
      } else if (med.type == 'ibuprofen') {
        medName = 'Ибупрофен';
        icon = '🔵';
        doseText = ': ${med.dose}мг';
      } else if (med.type.startsWith('custom_')) {
        medName = med.type.substring(7);
        icon = '🟣';
        doseText = '';
      } else {
        medName = med.type;
        icon = '🟣';
        doseText = '';
      }
      
      allRecords.add({
        'time': med.time,
        'text': '$icon ${DateFormat('dd.MM HH:mm').format(med.time)} - $medName$doseText',
        'type': 'medication',
      });
    }

    // Сортируем по времени (новые сверху)
    allRecords.sort((a, b) => b['time'].compareTo(a['time']));

    if (allRecords.isEmpty) {
      return Center(
        child: Text(
          'Нет записей',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: allRecords.take(10).map((record) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  record['text'],
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMedicationSection(String medType, MaterialColor color, String title, Map<String, double> dosage) {
    final controller = medType == 'paracetamol' ? paracetamolDoseController : ibuprofenDoseController;
    final selectedForm = medType == 'paracetamol' ? selectedParacetamolForm : selectedIbuprofenForm;
    final forms = medicationForms[medType]!;
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text('Максимум в сутки: ${dosage['maxDaily']} мг'),
          Text(
            'Дано сегодня: ${widget.child.getDailyDose(medType)} мг',
            style: TextStyle(
              color: widget.child.getDailyDose(medType) > dosage['maxDaily']! * 0.8 
                  ? Colors.red : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          
          // Выпадающий список форм
          DropdownButtonFormField<String>(
            value: selectedForm,
            decoration: InputDecoration(
              labelText: 'Выберите форму препарата',
              border: OutlineInputBorder(),
            ),
            items: forms.keys.map((String form) {
              return DropdownMenuItem<String>(
                value: form,
                child: Text(form, style: TextStyle(fontSize: 12)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              // Проверка для таблеток ибупрофена
              if (medType == 'ibuprofen' && newValue == 'Ибупрофен таблетки 200мг') {
                final ageInYears = widget.child.age >= 12 ? widget.child.age ~/ 12 : 0;
                if (widget.child.weight < 20 || ageInYears < 6) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('⚠️ Внимание!', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      content: Text('Данную форму лекарства не рекомендуется давать детям до 20 кг или младше 6 лет. Если ребёнку есть 6 лет, но он весит меньше 20 кг, можно при условии что он уверенно глотает таблетки'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              selectedIbuprofenForm = newValue;
                              controller.clear();
                            });
                          },
                          child: Text('Понятно, выбрать'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Отмена'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
              }
              
              setState(() {
                if (medType == 'paracetamol') {
                  selectedParacetamolForm = newValue;
                } else {
                  selectedIbuprofenForm = newValue;
                }
                controller.clear();
              });
            },
          ),
          
          if (selectedForm != null) ...[
            SizedBox(height: 12),
            _buildDoseRecommendation(medType, selectedForm!),
            SizedBox(height: 8),
            
            // Поле ввода дозы
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Введите дозу (${forms[selectedForm]!['unit']})',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _giveMedicationWithForm(medType, selectedForm!),
                  style: ElevatedButton.styleFrom(backgroundColor: color),
                  child: Text('Дать'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildDoseRecommendation(String medType, String form) {
    final formData = medicationForms[medType]![form]!;
    final weight = widget.child.weight.round();
    final doses = formData['doses'] as Map<int, Map<String, double>>?;
    
    // Проверяем ограничения по весу для разных форм
    String? weightWarning;
    Color warningColor = Colors.orange.shade700;
    
    if (form == 'Ибупрофен таблетки 200мг' && weight < 10) {
      weightWarning = '⚠️ Эта форма не рекомендуется детям с весом до 10 кг.';
    } else if (form == 'Ибупрофен свечи 125мг' && weight < 7) {
      weightWarning = '⚠️ Эта форма не рекомендуется детям с весом до 7 кг.';
    } else if (form == 'Ибупрофен свечи 60мг' && weight > 14) {
      weightWarning = '⚠️ Требуется два суппозитория. Лучше использовать свечи в дозировке 125 мг.';
    } else if (form == 'Ибупрофен свечи 125мг' && weight >= 30) {
      weightWarning = '⚠️ При достижении веса с 30 кг лучше выбирать иные формы препарата.';
    }
    
    if (doses != null && doses.containsKey(weight)) {
      final recommended = doses[weight]!['recommended']!;
      final max = doses[weight]!['max']!;
      final unit = formData['unit'];
      
      // Проверяем, есть ли нецелые дозы для свечей (не целые числа)
      bool hasNonWholeDose = unit == 'свечи' && (recommended != recommended.round() || max != max.round());
      
      return Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: weightWarning != null ? Colors.orange.shade50 : Colors.green.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: weightWarning != null ? Colors.orange.shade200 : Colors.green.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (weightWarning != null) ...[
              Text(
                weightWarning,
                style: TextStyle(color: warningColor, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
            ],
            Text(
              unit == 'мл' 
                ? 'Минимальная доза: $recommended $unit (оптимальная: $max $unit)'
                : unit == 'свечи'
                  ? 'Доза: $recommended $unit'
                  : 'Рекомендуемая доза: $recommended $unit (макс. $max $unit)',
              style: TextStyle(color: weightWarning != null ? Colors.orange.shade700 : Colors.green.shade700, fontWeight: FontWeight.w500),
            ),
            if (hasNonWholeDose) ...[
              SizedBox(height: 4),
              Text(
                '⚠️ Делить ректальные суппозитории (свечи) не рекомендуется. Поэтому лучше найти более подходящую форму лекарства. Если решили разделить – лучше резать вдоль, так удобней вводить.',
                style: TextStyle(color: Colors.orange.shade700, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      );
    }
    
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('Нет данных для веса ${weight}кг'),
    );
  }
  
  void _giveMedicationWithForm(String medType, String form) {
    final controller = medType == 'paracetamol' ? paracetamolDoseController : ibuprofenDoseController;
    final doseText = controller.text.trim().replaceAll(',', '.');
    final dose = double.tryParse(doseText);
    
    if (dose == null || dose <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Введите корректную дозу'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final formData = medicationForms[medType]![form]!;
    final concentration = formData['concentration'] as double;
    final doseInMg = dose * concentration;
    
    // Проверка максимальной разовой дозы
    final weight = widget.child.weight.round();
    final doses = formData['doses'] as Map<int, Map<String, double>>?;
    
    if (doses != null && doses.containsKey(weight)) {
      final maxDose = doses[weight]!['max']! * concentration;
      if (doseInMg > maxDose) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('⚠️ Превышение дозы!'),
            content: Text('Введенная доза (${doseInMg.round()}мг) превышает максимальную разовую дозу (${maxDose.round()}мг)!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  giveMedication(medType, doseInMg);
                  controller.clear();
                },
                child: Text('Всё равно дать'),
              ),
            ],
          ),
        );
        return;
      }
    }
    
    giveMedication(medType, doseInMg);
    controller.clear();
  }
  
  Widget _buildCustomMedicationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: customMedNameController,
          decoration: InputDecoration(
            labelText: 'Название лекарства',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _markCustomMedicationTaken,
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4A90A4)),
                child: Text('Отметить приём'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    showCustomMedForm = !showCustomMedForm;
                    if (!showCustomMedForm) {
                      _resetCustomMedForm();
                    } else {
                      _editingMedication = null; // Сбрасываем режим редактирования
                    }
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF81C784)),
                child: Text('Создать курс'),
              ),
            ),
          ],
        ),
        if (showCustomMedForm) ...[
          SizedBox(height: 12),
          _buildCustomMedForm(),
        ],
        if (widget.child.customMedications.isNotEmpty) ...[
          SizedBox(height: 12),
          _buildCustomMedList(),
        ],
      ],
    );
  }
  
  Widget _buildCustomMedForm() {
    return Column(
      children: [
        Row(
          children: [
            Text('Приёмов в сутки: '),
            SizedBox(width: 8),
            DropdownButton<int>(
              value: dailyDoses,
              items: List.generate(6, (index) => index + 1)
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  dailyDoses = value ?? 1;
                  selectedTimes = List.generate(
                    dailyDoses,
                    (index) => TimeOfDay(hour: 8 + (index * 4), minute: 0),
                  );
                });
              },
            ),
          ],
        ),
        SizedBox(height: 12),
        ...List.generate(dailyDoses, (index) => _buildTimeSelector(index)),
        SizedBox(height: 12),
        Row(
          children: [
            Text('Продолжительность (дней): '),
            SizedBox(width: 8),
            DropdownButton<int>(
              value: durationDays,
              items: List.generate(30, (index) => index + 1)
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  durationDays = value ?? 1;
                });
              },
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: wantsReminders,
              onChanged: (value) {
                setState(() {
                  wantsReminders = value ?? false;
                });
              },
            ),
            Text('Получать напоминания'),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            if (_editingMedication != null) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveEditedMedication,
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF81C784)),
                  child: Text('Сохранить изменения'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _cancelEdit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text('Назад'),
                ),
              ),
            ] else
              Expanded(
                child: ElevatedButton(
                  onPressed: _addCustomMedication,
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF81C784)),
                  child: Text('Создать курс'),
                ),
              ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTimeSelector(int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('Приём ${index + 1}: '),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () => _selectTime(index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${selectedTimes[index].hour.toString().padLeft(2, '0')}:${selectedTimes[index].minute.toString().padLeft(2, '0')}',
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCustomMedList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Активные курсы:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ...widget.child.customMedications.map((med) => _buildCustomMedItem(med)).toList(),
      ],
    );
  }
  
  Widget _buildCustomMedItem(CustomMedication med) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(med.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text('Осталось: ${med.remainingDays} дней'),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _takeCustomMedication(med.name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4A90A4),
                    ),
                    child: Text('Принять'),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editCustomMedication(med),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeCustomMedication(med),
                ),
              ],
            ),
            if (med.hasReminders) ...[
              SizedBox(height: 8),
              ExpansionTile(
                title: Text('Подробности', style: TextStyle(fontSize: 14)),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Напоминания: включены', style: TextStyle(fontWeight: FontWeight.w500)),
                        SizedBox(height: 4),
                        Text('Приёмов в день: ${med.dailyDoses}'),
                        SizedBox(height: 4),
                        Text('Время приёма: ${med.times.map((t) => "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}").join(", ")}'),
                        SizedBox(height: 4),
                        Text('Продолжительность: ${med.durationDays} дней'),
                        SizedBox(height: 8),
                        Text('Начато: ${DateFormat('dd.MM.yyyy').format(med.startDate)}'),
                      ],
                    ),
                  ),
                ],
              ),
            ] else
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Напоминания: отключены'),
              ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _selectTime(int index) async {
    await showDialog(
      context: context,
      builder: (context) => _TimePickerDialog(
        initialTime: selectedTimes[index],
        onTimeSelected: (time) {
          setState(() {
            selectedTimes[index] = time;
          });
        },
      ),
    );
  }
  
  void _markCustomMedicationTaken() {
    final name = customMedNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Введите название лекарства'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      widget.child.medicationLog.add(
        MedicationRecord(
          time: DateTime.now(),
          type: 'custom_$name',
          dose: 0,
        ),
      );
    });
    
    customMedNameController.clear();
    
    final timeStr = DateFormat('HH:mm').format(DateTime.now());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name принят в $timeStr'),
        backgroundColor: Color(0xFF4A90A4),
      ),
    );
  }
  
  void _addCustomMedication() {
    final name = customMedNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Введите название лекарства'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final medication = CustomMedication(
      name: name,
      hasReminders: wantsReminders,
      dailyDoses: wantsReminders ? dailyDoses : 0,
      times: wantsReminders ? List.from(selectedTimes) : [],
      durationDays: durationDays,
      startDate: DateTime.now(),
    );
    
    setState(() {
      widget.child.customMedications.add(medication);
      showCustomMedForm = false;
    });
    
    _resetCustomMedForm();
    
    if (wantsReminders) {
      _scheduleNotifications(medication);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Курс "$name" создан'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  CustomMedication? _editingMedication;
  
  void _editCustomMedication(CustomMedication med) {
    _editingMedication = med;
    customMedNameController.text = med.name;
    wantsReminders = med.hasReminders;
    dailyDoses = med.dailyDoses > 0 ? med.dailyDoses : 1;
    selectedTimes = med.times.isNotEmpty ? List.from(med.times) : [TimeOfDay(hour: 8, minute: 0)];
    durationDays = med.durationDays;
    
    setState(() {
      showCustomMedForm = true;
    });
  }
  
  void _removeCustomMedication(CustomMedication med) {
    setState(() {
      widget.child.customMedications.remove(med);
    });
    
    NotificationService.cancelMedicationReminders(med);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Лекарство "${med.name}" удалено'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  void _resetCustomMedForm() {
    customMedNameController.clear();
    wantsReminders = false;
    dailyDoses = 1;
    selectedTimes = [TimeOfDay(hour: 8, minute: 0)];
    durationDays = 1;
    _editingMedication = null;
  }
  
  void _saveEditedMedication() {
    final name = customMedNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Введите название лекарства'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_editingMedication != null) {
      // Отменяем старые уведомления
      NotificationService.cancelMedicationReminders(_editingMedication!);
      
      // Обновляем данные
      setState(() {
        _editingMedication!.name = name;
        _editingMedication!.hasReminders = wantsReminders;
        _editingMedication!.dailyDoses = wantsReminders ? dailyDoses : 0;
        _editingMedication!.times = wantsReminders ? List.from(selectedTimes) : [];
        _editingMedication!.durationDays = durationDays;
        showCustomMedForm = false;
      });
      
      // Настраиваем новые уведомления
      if (wantsReminders) {
        _scheduleNotifications(_editingMedication!);
      }
      
      _resetCustomMedForm();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Курс "$name" обновлен'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void _cancelEdit() {
    setState(() {
      showCustomMedForm = false;
    });
    _resetCustomMedForm();
  }
  
  void _scheduleNotifications(CustomMedication medication) {
    NotificationService.scheduleMedicationReminders(medication);
  }
  
  void _takeCustomMedication(String medName) {
    if (!mounted) return;
    
    setState(() {
      widget.child.medicationLog.add(
        MedicationRecord(
          time: DateTime.now(),
          type: 'custom_$medName',
          dose: 0,
        ),
      );
    });
    
    final timeStr = DateFormat('HH:mm').format(DateTime.now());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$medName принят в $timeStr'),
          backgroundColor: Color(0xFF4A90A4),
        ),
      );
    }
  }
  
  void _generateReport() async {
    // Получаем все типы лекарств
    Set<String> allMedTypes = {};
    for (var med in widget.child.medicationLog) {
      allMedTypes.add(med.type);
    }
    for (var customMed in widget.child.customMedications) {
      allMedTypes.add('custom_${customMed.name}');
    }
    
    if (allMedTypes.isEmpty && widget.child.temperatureLog.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Нет данных для отчёта')),
      );
      return;
    }
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ReportConfigDialog(
        availableMedTypes: allMedTypes.toList(),
        temperatureLog: widget.child.temperatureLog,
      ),
    );
    
    if (result != null) {
      await _createPdfReport(
        result['selectedMeds'] as List<String>,
        result['startDate'] as DateTime,
        result['endDate'] as DateTime,
      );
    }
  }
  
  Future<void> _createPdfReport(List<String> selectedMeds, DateTime startDate, DateTime endDate) async {
    try {
      final pdf = pw.Document();
      
      // Используем встроенные шрифты PDF библиотеки
      final font = pw.Font.helvetica();
      final fontBold = pw.Font.helveticaBold();
      
      // Фильтруем данные по периоду
      final filteredTemps = widget.child.temperatureLog
          .where((t) => t.time.isAfter(startDate) && t.time.isBefore(endDate))
          .toList();
      
      final filteredMeds = widget.child.medicationLog
          .where((m) => m.time.isAfter(startDate) && m.time.isBefore(endDate) && selectedMeds.contains(m.type))
          .toList();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: font,
            bold: fontBold,
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('Otchet o sostoyanii ${widget.child.name}', style: pw.TextStyle(font: fontBold, fontSize: 20)),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Period: ${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}', style: pw.TextStyle(font: font)),
                pw.SizedBox(height: 20),
                
                // История наблюдений
                pw.Text('Istoriya nablyudeniy:', style: pw.TextStyle(font: fontBold, fontSize: 16)),
                pw.SizedBox(height: 10),
                
                ...filteredTemps.map((temp) => pw.Padding(
                  padding: pw.EdgeInsets.only(bottom: 5),
                  child: pw.Text('Temperatura: ${DateFormat('dd.MM HH:mm').format(temp.time)} - ${temp.value}C', style: pw.TextStyle(font: font)),
                )),
                
                ...filteredMeds.map((med) {
                  String medName;
                  if (med.type == 'paracetamol') {
                    medName = 'Paracetamol';
                  } else if (med.type == 'ibuprofen') {
                    medName = 'Ibuprofen';
                  } else if (med.type.startsWith('custom_')) {
                    medName = med.type.substring(7);
                  } else {
                    medName = med.type;
                  }
                  
                  return pw.Padding(
                    padding: pw.EdgeInsets.only(bottom: 5),
                    child: pw.Text('$medName: ${DateFormat('dd.MM HH:mm').format(med.time)} - ${med.dose > 0 ? "${med.dose}mg" : "prinyato"}', style: pw.TextStyle(font: font)),
                  );
                }),
                
                pw.SizedBox(height: 20),
                pw.Text('Statistika:', style: pw.TextStyle(font: fontBold, fontSize: 16)),
                pw.SizedBox(height: 10),
                pw.Text('Vsego zamerov temperatury: ${filteredTemps.length}', style: pw.TextStyle(font: font)),
                pw.Text('Vsego priemov lekarstv: ${filteredMeds.length}', style: pw.TextStyle(font: font)),
                if (filteredTemps.isNotEmpty) ...[
                  pw.Text('Maksimalnaya temperatura: ${filteredTemps.map((t) => t.value).reduce((a, b) => a > b ? a : b)}C', style: pw.TextStyle(font: font)),
                  pw.Text('Minimalnaya temperatura: ${filteredTemps.map((t) => t.value).reduce((a, b) => a < b ? a : b)}C', style: pw.TextStyle(font: font)),
                ],
              ],
            );
          },
        ),
      );
      
      // Генерируем PDF
      final pdfBytes = await pdf.save();
      
      // Сохраняем файл
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Отчет_${widget.child.name}_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      
      // Предлагаем поделиться файлом
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Отчёт о состоянии ${widget.child.name}',
      );
      
      // Показываем сообщение об успешном создании
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF отчёт создан и готов к отправке'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('PDF Error: $e'); // Отладочная информация
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка создания PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
}

class _TimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeSelected;

  _TimePickerDialog({required this.initialTime, required this.onTimeSelected});

  @override
  _TimePickerDialogState createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<_TimePickerDialog> {
  late int selectedHour;
  late int selectedMinute;
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialTime.hour;
    selectedMinute = widget.initialTime.minute;
    hourController = FixedExtentScrollController(initialItem: selectedHour);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute ~/ 5);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Выберите время'),
      content: Container(
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text('Часы', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: hourController,
                      itemExtent: 40,
                      physics: FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedHour = index;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          if (index < 0 || index > 23) return null;
                          return Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: selectedHour == index ? FontWeight.bold : FontWeight.normal,
                                color: selectedHour == index ? Colors.blue : Colors.black,
                              ),
                            ),
                          );
                        },
                        childCount: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Expanded(
              child: Column(
                children: [
                  Text('Минуты', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: minuteController,
                      itemExtent: 40,
                      physics: FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedMinute = index * 5;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          if (index < 0 || index > 11) return null;
                          final minute = index * 5;
                          return Center(
                            child: Text(
                              minute.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: selectedMinute == minute ? FontWeight.bold : FontWeight.normal,
                                color: selectedMinute == minute ? Colors.blue : Colors.black,
                              ),
                            ),
                          );
                        },
                        childCount: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            widget.onTimeSelected(TimeOfDay(hour: selectedHour, minute: selectedMinute));
            Navigator.pop(context);
          },
          child: Text('ОК'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }
}

class _ReportConfigDialog extends StatefulWidget {
  final List<String> availableMedTypes;
  final List<TemperatureRecord> temperatureLog;

  _ReportConfigDialog({required this.availableMedTypes, required this.temperatureLog});

  @override
  _ReportConfigDialogState createState() => _ReportConfigDialogState();
}

class _ReportConfigDialogState extends State<_ReportConfigDialog> {
  List<String> selectedMeds = [];
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    selectedMeds = List.from(widget.availableMedTypes);
    
    if (widget.temperatureLog.isNotEmpty) {
      final now = DateTime.now();
      endDate = now;
      startDate = now.subtract(Duration(days: 7));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Настройка отчёта'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Период:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now().subtract(Duration(days: 7)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          startDate = date;
                        });
                      }
                    },
                    child: Text(startDate != null ? DateFormat('dd.MM.yyyy').format(startDate!) : 'Начало'),
                  ),
                ),
                Text(' - '),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: startDate ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          endDate = date;
                        });
                      }
                    },
                    child: Text(endDate != null ? DateFormat('dd.MM.yyyy').format(endDate!) : 'Конец'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Препараты:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ...widget.availableMedTypes.map((medType) {
              String displayName = medType;
              if (medType == 'paracetamol') displayName = 'Парацетамол';
              else if (medType == 'ibuprofen') displayName = 'Ибупрофен';
              else if (medType.startsWith('custom_')) displayName = medType.substring(7);
              
              return CheckboxListTile(
                title: Text(displayName),
                value: selectedMeds.contains(medType),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedMeds.add(medType);
                    } else {
                      selectedMeds.remove(medType);
                    }
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена'),
        ),
        TextButton(
          onPressed: startDate != null && endDate != null
              ? () {
                  Navigator.pop(context, {
                    'selectedMeds': selectedMeds,
                    'startDate': startDate,
                    'endDate': endDate,
                  });
                }
              : null,
          child: Text('Создать'),
        ),
      ],
    );
  }
}
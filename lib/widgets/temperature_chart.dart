import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/child.dart';
import 'package:intl/intl.dart';

class TemperatureChart extends StatelessWidget {
  final Child child;

  TemperatureChart({required this.child});

  @override
  Widget build(BuildContext context) {
    // Проверяем есть ли данные за последние 24 часа
    final now = DateTime.now();
    final dayAgo = now.subtract(Duration(hours: 24));
    
    final recentTemps = child.temperatureLog
        .where((temp) => temp.time.isAfter(dayAgo))
        .toList();
    
    final recentMeds = child.medicationLog
        .where((med) => med.time.isAfter(dayAgo))
        .toList();

    // Если нет данных за сутки - обнуляем график
    if (recentTemps.isEmpty && recentMeds.isEmpty) {
      return Center(
        child: Text(
          'Нет данных за последние 24 часа',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Определяем временное окно (4 часа от первой точки)
    DateTime startTime;
    if (recentTemps.isNotEmpty) {
      startTime = recentTemps.first.time;
    } else {
      startTime = now.subtract(Duration(hours: 4));
    }
    final endTime = startTime.add(Duration(hours: 4));

    // Фильтруем данные по 4-часовому окну
    final windowTemps = child.temperatureLog
        .where((temp) => temp.time.isAfter(startTime.subtract(Duration(minutes: 1))) && temp.time.isBefore(endTime))
        .toList();
    
    final windowMeds = child.medicationLog
        .where((med) => med.time.isAfter(startTime.subtract(Duration(minutes: 1))) && med.time.isBefore(endTime))
        .toList();
        
    // Добавляем пользовательские лекарства (симуляция приёмов)
    List<MedicationRecord> customMedRecords = [];
    for (var customMed in child.customMedications) {
      if (customMed.hasReminders) {
        for (int day = 0; day < customMed.durationDays; day++) {
          for (var time in customMed.times) {
            final medTime = DateTime(
              customMed.startDate.year,
              customMed.startDate.month,
              customMed.startDate.day + day,
              time.hour,
              time.minute,
            );
            if (medTime.isAfter(startTime) && medTime.isBefore(endTime)) {
              customMedRecords.add(MedicationRecord(
                time: medTime,
                type: 'custom',
                dose: 0,
              ));
            }
          }
        }
      }
    }
    windowMeds.addAll(customMedRecords);

    // Фиксированный диапазон температур с возможностью расширения
    double minTemp = 35.0;
    double maxTemp = 40.0;
    
    if (windowTemps.isNotEmpty) {
      final tempValues = windowTemps.map((t) => t.value).toList();
      final dataMin = tempValues.reduce((a, b) => a < b ? a : b);
      final dataMax = tempValues.reduce((a, b) => a > b ? a : b);
      
      // Расширяем границы только при необходимости
      if (dataMin < minTemp) {
        minTemp = (dataMin - 0.5).floorToDouble();
      }
      if (dataMax > maxTemp) {
        maxTemp = (dataMax + 0.5).ceilToDouble();
      }
    }

    // Создаем точки для графика
    List<FlSpot> spots = [];
    for (var temp in windowTemps) {
      final hoursSinceStart = temp.time.difference(startTime).inMinutes / 60.0;
      spots.add(FlSpot(hoursSinceStart, temp.value));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 0.5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 0.5,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 0.5,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value > 4) return Container();
                final time = startTime.add(Duration(minutes: (value * 60).round()));
                return Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('HH:mm').format(time),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: 1.0,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    '${value.toStringAsFixed(1)}°',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
        minX: 0,
        maxX: 4,
        minY: minTemp,
        maxY: maxTemp,
        lineBarsData: [
          if (spots.isNotEmpty)
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.red,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.red,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withOpacity(0.1),
              ),
            ),
          ..._buildMedicationBars(windowMeds, windowTemps, startTime, minTemp, maxTemp),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final time = startTime.add(Duration(minutes: (barSpot.x * 60).round()));
                final timeStr = DateFormat('HH:mm').format(time);
                
                if (barSpot.barIndex == 0) {
                  // Температура
                  return LineTooltipItem(
                    'Температура: ${barSpot.y.toStringAsFixed(1)}°C\n$timeStr',
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                } else {
                  // Находим лекарство по времени
                  String medName = 'Лекарство';
                  
                  // Находим ближайшее лекарство по времени
                  double minDiff = double.infinity;
                  String? closestMedType;
                  
                  for (var med in windowMeds) {
                    final medTime = med.time.difference(startTime).inMinutes / 60.0;
                    final diff = (medTime - barSpot.x).abs();
                    if (diff < minDiff) {
                      minDiff = diff;
                      closestMedType = med.type;
                    }
                  }
                  
                  if (closestMedType != null && minDiff < 0.2) { // Примерно 12 минут
                    if (closestMedType == 'paracetamol') {
                      medName = 'Парацетамол';
                    } else if (closestMedType == 'ibuprofen') {
                      medName = 'Ибупрофен';
                    } else if (closestMedType.startsWith('custom_')) {
                      medName = closestMedType.substring(7);
                    } else if (closestMedType == 'custom') {
                      medName = 'Пользовательское';
                    }
                  }
                  
                  return LineTooltipItem(
                    '$medName\n$timeStr',
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }
              }).toList();
            },
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 38.5,
              color: Colors.orange.withOpacity(0.7),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ],
        ),
      ),
    );
  }
  
  List<LineChartBarData> _buildMedicationBars(
    List<MedicationRecord> meds, 
    List<TemperatureRecord> temps, 
    DateTime startTime,
    double minTemp,
    double maxTemp
  ) {
    List<FlSpot> paraSpots = [];
    List<FlSpot> ibuSpots = [];
    List<FlSpot> customSpots = [];
    
    for (var med in meds) {
      final hoursSinceStart = med.time.difference(startTime).inMinutes / 60.0;
      
      // Ищем ближайший замер температуры (в пределах 15 минут)
      TemperatureRecord? nearestTemp;
      double minDiff = double.infinity;
      
      for (var temp in temps) {
        final diff = (temp.time.difference(med.time).inMinutes).abs();
        if (diff <= 15 && diff < minDiff) {
          minDiff = diff.toDouble();
          nearestTemp = temp;
        }
      }
      
      // Определяем Y координату для маркера
      double yPosition = nearestTemp?.value ?? 37.0;
      if (nearestTemp != null) {
        yPosition += 0.2; // Чуть выше точки температуры
      }
      
      if (med.type == 'paracetamol') {
        paraSpots.add(FlSpot(hoursSinceStart, yPosition));
      } else if (med.type == 'ibuprofen') {
        ibuSpots.add(FlSpot(hoursSinceStart, yPosition));
      } else if (med.type == 'custom' || med.type.startsWith('custom_')) {
        customSpots.add(FlSpot(hoursSinceStart, yPosition));
      }
    }
    
    List<LineChartBarData> bars = [];
    
    // Всегда добавляем в фиксированном порядке, даже если список пустой
    // 1. Парацетамол
    bars.add(
      LineChartBarData(
        spots: paraSpots,
        isCurved: false,
        color: Colors.orange,
        barWidth: 0,
        dotData: FlDotData(
          show: paraSpots.isNotEmpty,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotSquarePainter(
              size: 8,
              color: Colors.orange,
              strokeWidth: 1,
              strokeColor: Colors.white,
            );
          },
        ),
      ),
    );
    
    // 2. Ибупрофен
    bars.add(
      LineChartBarData(
        spots: ibuSpots,
        isCurved: false,
        color: Colors.blue,
        barWidth: 0,
        dotData: FlDotData(
          show: ibuSpots.isNotEmpty,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: Colors.blue,
              strokeWidth: 1,
              strokeColor: Colors.white,
            );
          },
        ),
      ),
    );
    
    // 3. Пользовательские
    bars.add(
      LineChartBarData(
        spots: customSpots,
        isCurved: false,
        color: Color(0xFF81C784),
        barWidth: 0,
        dotData: FlDotData(
          show: customSpots.isNotEmpty,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotTrianglePainter(
              size: 8,
              color: Color(0xFF81C784),
              strokeWidth: 1,
              strokeColor: Colors.white,
            );
          },
        ),
      ),
    );
    
    return bars;
  }
}

class FlDotSquarePainter extends FlDotPainter {
  final double size;
  final Color color;
  final double strokeWidth;
  final Color strokeColor;

  FlDotSquarePainter({
    required this.size,
    required this.color,
    this.strokeWidth = 0,
    this.strokeColor = Colors.transparent,
  });

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromCenter(
      center: offsetInCanvas,
      width: size,
      height: size,
    );

    canvas.drawRect(rect, paint);
    if (strokeWidth > 0) {
      canvas.drawRect(rect, strokePaint);
    }
  }

  @override
  Size getSize(FlSpot spot) {
    return Size(size, size);
  }

  @override
  Color get mainColor => color;

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    return this;
  }

  @override
  List<Object?> get props => [size, color, strokeWidth, strokeColor];
}

class FlDotTrianglePainter extends FlDotPainter {
  final double size;
  final Color color;
  final double strokeWidth;
  final Color strokeColor;

  FlDotTrianglePainter({
    required this.size,
    required this.color,
    this.strokeWidth = 0,
    this.strokeColor = Colors.transparent,
  });

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    final halfSize = size / 2;
    
    path.moveTo(offsetInCanvas.dx, offsetInCanvas.dy - halfSize);
    path.lineTo(offsetInCanvas.dx - halfSize, offsetInCanvas.dy + halfSize);
    path.lineTo(offsetInCanvas.dx + halfSize, offsetInCanvas.dy + halfSize);
    path.close();

    canvas.drawPath(path, paint);
    if (strokeWidth > 0) {
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  Size getSize(FlSpot spot) {
    return Size(size, size);
  }

  @override
  Color get mainColor => color;

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    return this;
  }

  @override
  List<Object?> get props => [size, color, strokeWidth, strokeColor];
}
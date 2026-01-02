import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/event_detail_model.dart';

class EventPieChartWidget extends StatelessWidget {
  final EventDetail event;

  const EventPieChartWidget({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int nonConfirmed = event.totalConfirmations - event.confirmedCount;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Répartition des confirmations", style: _textStyleBold),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: event.confirmedCount.toDouble(),
                      title: 'Confirmé\n${event.confirmedCount}',
                      radius: 60,
                      titleStyle: _pieChartTextStyle,
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: nonConfirmed.toDouble(),
                      title: 'Non Confirmé\n$nonConfirmed',
                      radius: 60,
                      titleStyle: _pieChartTextStyle,
                    ),
                  ],
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _textStyleBold =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static const _pieChartTextStyle =
      TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white);
}

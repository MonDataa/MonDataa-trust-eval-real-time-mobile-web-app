import 'package:flutter/material.dart';
import '../models/event_detail_model.dart';

class EventStatsWidget extends StatelessWidget {
  final EventDetail event;

  const EventStatsWidget({Key? key, required this.event}) : super(key: key);

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
            const Text("Statistiques de confirmation", style: _textStyleBold),
            const Divider(),
            _buildInfoRow(Icons.check_circle, "Confirmations",
                "${event.totalConfirmations}"),
            _buildInfoRow(Icons.done, "Confirmés", "${event.confirmedCount}"),
            _buildInfoRow(Icons.close, "Non Confirmés", "$nonConfirmed"),
            _buildInfoRow(Icons.percent, "Taux de Confirmation",
                "${event.confirmationRate}%"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 10),
        Text("$label : ", style: _textStyleBold),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  static const _textStyleBold =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
}

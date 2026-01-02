import 'package:flutter/material.dart';
import '../models/event_detail_model.dart';

class EventConfidenceScoreWidget extends StatelessWidget {
  final EventDetail event;

  const EventConfidenceScoreWidget({Key? key, required this.event})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Score de Confiance", style: _textStyleBold),
            const SizedBox(height: 10),
            Text(
              "${event.confidenceScore}%",
              style: _textStyleTitle,
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: event.confidenceScore / 100,
              backgroundColor: Colors.grey[300],
              color: event.confidenceScore > 50 ? Colors.green : Colors.red,
              minHeight: 10,
            ),
          ],
        ),
      ),
    );
  }

  static const _textStyleTitle =
      TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const _textStyleBold =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
}

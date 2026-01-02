import 'package:flutter/material.dart';
import '../models/event_detail_model.dart';

class EventLocationWidget extends StatelessWidget {
  final EventDetail event;

  const EventLocationWidget({Key? key, required this.event}) : super(key: key);

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
            const Text("Localisation", style: _textStyleBold),
            const Divider(),
            _buildInfoRow(Icons.map, "Latitude", "${event.latitude}"),
            _buildInfoRow(Icons.map, "Longitude", "${event.longitude}"),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_detail_model.dart';

class EventDetailCard extends StatelessWidget {
  final EventDetail event;
  final bool isExpired;

  const EventDetailCard(
      {Key? key, required this.event, required this.isExpired})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedStartDate =
        DateFormat('dd MMM yyyy - HH:mm').format(event.eventTime);
    String formattedExpirationDate =
        DateFormat('dd MMM yyyy - HH:mm').format(event.expirationTime);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: _textStyleTitle),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.place, "Lieu", event.locationName),
            _buildInfoRow(Icons.location_on, "Zone", event.zone),
            _buildInfoRow(Icons.access_time, "Début", formattedStartDate),
            _buildInfoRow(Icons.timer_off, "Expire", formattedExpirationDate,
                color: isExpired ? Colors.red : Colors.green),
            Row(
              children: [
                _buildChip("Status",
                    event.status == "CONFIRMED" ? Colors.green : Colors.orange),
                const SizedBox(width: 8),
                _buildChip("Expiré", isExpired ? Colors.red : Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.black54),
        const SizedBox(width: 10),
        Text("$label : ", style: _textStyleBold),
        Text(value),
      ],
    );
  }

  Widget _buildChip(String text, Color color) {
    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  static const _textStyleTitle =
      TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static const _textStyleBold =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
}

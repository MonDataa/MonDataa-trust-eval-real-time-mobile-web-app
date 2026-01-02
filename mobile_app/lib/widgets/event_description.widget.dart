import 'package:flutter/material.dart';
import '../models/event_detail_model.dart';

class EventDescriptionWidget extends StatelessWidget {
  final EventDetail event;

  const EventDescriptionWidget({Key? key, required this.event})
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
            const Text("Description", style: _textStyleBold),
            const Divider(),
            Text(
              event.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  static const _textStyleBold =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
}

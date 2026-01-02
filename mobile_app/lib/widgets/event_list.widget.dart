import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import '../blocs/home/app_blocs.dart';
import '../blocs/home/app_events.dart';
import '../blocs/home/app_states.dart';
import '../models/EventModel.dart';
import '../pages/details_event.page.dart';
import 'pagination_events_controls.widget.dart';

class EventListWidget extends StatefulWidget {
  final List<EventModel> events;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const EventListWidget({
    super.key,
    required this.events,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  _EventListWidgetState createState() => _EventListWidgetState();
}

class _EventListWidgetState extends State<EventListWidget> {
  Future<String?> _getLocalImagePath(String imageName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fullPath = "${directory.path}/$imageName";

      if (await File(fullPath).exists()) {
        return fullPath;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<EventBloc>()
            .add(const LoadEventEvent(usePagination: true));
      },
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: widget.events.length,
              itemBuilder: (context, index) {
                final event = widget.events[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FutureBuilder<String?>(
                    future: _getLocalImagePath(event.imageName),
                    builder: (context, snapshot) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DetailEvent(eventId: event.id)),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// 🖼 **Image on Top**
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12)),
                                child: snapshot.connectionState ==
                                        ConnectionState.waiting
                                    ? const SizedBox(
                                        height: 180,
                                        child: Center(
                                            child: CircularProgressIndicator()))
                                    : snapshot.hasError ||
                                            snapshot.data == null ||
                                            !File(snapshot.data!).existsSync()
                                        ? Container(
                                            height: 180,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                                Icons.broken_image,
                                                size: 50,
                                                color: Colors.red),
                                          )
                                        : Image.file(
                                            File(snapshot.data!),
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                              ),

                              /// 📋 **Event Details Below**
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "📍 ${event.locationName} - Zone: ${event.zone}",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "🗓 ${event.expirationTime}",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          PaginationEventsControls(
            currentPage: widget.currentPage,
            totalPages: widget.totalPages,
            onPageChanged: widget.onPageChanged,
          ),
        ],
      ),
    );
  }
}

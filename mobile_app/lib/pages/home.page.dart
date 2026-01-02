/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import '../blocs/home/app_blocs.dart';
import '../blocs/home/app_events.dart';
import '../blocs/home/app_states.dart';
import '../models/EventModel.dart';
import '../widgets/appbar_item.widget.dart';
import '../widgets/custom_drawer.widgets.dart';
import '../widgets/pagination_events_controls.widget.dart';
import '../widgets/map_events.widget.dart';
import 'details_event.page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<EventModel> _selectedEvents = [];
  List<EventModel> _filteredEvents = [];
  final TextEditingController _searchController = TextEditingController();
  final int _pageSize = 8;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      final eventBloc = context.read<EventBloc>();
      eventBloc.add(LoadEventEvent(
          page: _currentPage, size: _pageSize, usePagination: true));
      eventBloc.add(const LoadEventEvent(usePagination: false));
    }
  }

  /// 📂 **Récupérer le chemin d'une image locale**
  Future<String?> _getLocalImagePath(String imageName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fullPath = "${directory.path}/$imageName";

      print("📌 Vérification du chemin : $fullPath");

      if (await File(fullPath).exists()) {
        print("✅ Image trouvée : $fullPath");
        return fullPath;
      } else {
        print("❌ Image introuvable : $fullPath");
        return null;
      }
    } catch (e) {
      print("⚠️ Erreur lors de la récupération de l'image : $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: const CustomAppBar(title: "Liste des événements"),
      body: Column(
        children: [
          SizedBox(
            height: 400,
            child: MapEventWidget(
              onEventsSelected: (events) {
                setState(() {
                  _selectedEvents = events;
                  _filteredEvents = events;
                });
              },
              onFilterChanged: (events) {
                setState(() {
                  _filteredEvents = List.from(events);
                });
                print(
                    "📌 HomePage: Événements visibles mis à jour: ${events.length}");
                print(
                    "📌 HomePage: Événements visibles mis à jour: ${events[0].imageName}");
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<EventBloc, EventState>(
              builder: (context, state) {
                if (state is EventLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is EventLoadedState) {
                  return _buildEventList(state);
                } else if (state is EventErrorState) {
                  return Center(child: Text("Erreur : ${state.errors}"));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔍 **Filtrer les événements**
  void _filterEvents(String query) {
    setState(() {
      _filteredEvents = _selectedEvents.where((event) {
        return event.title.toLowerCase().contains(query.toLowerCase()) ||
            event.locationName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  /// 📝 **Liste des événements**
  Widget _buildEventList(EventLoadedState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<EventBloc>()
            .add(LoadEventEvent(page: 0, size: _pageSize, usePagination: true));
      },
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _filteredEvents.length,
              itemBuilder: (context, index) {
                final event = _filteredEvents[index];
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
            currentPage: state.currentPage,
            totalPages: state.totalPages,
            onPageChanged: (newPage) {
              setState(() {
                _currentPage = newPage;
              });
              context.read<EventBloc>().add(LoadEventEvent(
                  page: newPage, size: _pageSize, usePagination: true));
            },
          ),
        ],
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/home/app_blocs.dart';
import '../blocs/home/app_events.dart';
import '../blocs/home/app_states.dart';
import '../models/EventModel.dart';
import '../widgets/appbar_item.widget.dart';
import '../widgets/custom_drawer.widgets.dart';
import '../widgets/event_list.widget.dart';
import '../widgets/map_events.widget.dart';
import '../widgets/gradient_background.widget.dart';
import '../widgets/search_bar.widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<EventModel> _selectedEvents = [];
  List<EventModel> _filteredEvents = [];
  final TextEditingController _searchController = TextEditingController();
  final int _pageSize = 8;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // ✅ Fond dégradé sous l'AppBar
      appBar: const CustomAppBar(title: "Liste des événements"),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          const GradientBackgroundWidget(), // ✅ Ajout du fond dégradé
          Column(
            children: [
              SizedBox(
                height: 400,
                child: MapEventWidget(
                  onEventsSelected: (events) {
                    setState(() {
                      _selectedEvents = events;
                      _filteredEvents = events;
                    });
                  },
                  onFilterChanged: (events) {
                    setState(() {
                      _filteredEvents = List.from(events);
                    });
                  },
                ),
              ),
              Expanded(
                child: BlocBuilder<EventBloc, EventState>(
                  builder: (context, state) {
                    if (state is EventLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is EventLoadedState) {
                      return EventListWidget(
                        events: _filteredEvents,
                        currentPage: _currentPage,
                        totalPages: state.totalPages,
                        onPageChanged: (newPage) {
                          setState(() {
                            _currentPage = newPage;
                          });
                          context.read<EventBloc>().add(LoadEventEvent(
                              page: newPage,
                              size: _pageSize,
                              usePagination: true));
                        },
                      );
                    } else if (state is EventErrorState) {
                      return Center(child: Text("Erreur : ${state.errors}"));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔍 **Filtrer les événements**
  void _filterEvents(String query) {
    setState(() {
      _filteredEvents = _selectedEvents.where((event) {
        return event.title.toLowerCase().contains(query.toLowerCase()) ||
            event.locationName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }
}

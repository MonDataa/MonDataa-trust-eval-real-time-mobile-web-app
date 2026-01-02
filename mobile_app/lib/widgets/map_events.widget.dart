import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_app/blocs/home/app_blocs.dart';
import 'package:mobile_app/blocs/home/app_states.dart';
import 'package:mobile_app/models/EventModel.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:path_provider/path_provider.dart';

import '../blocs/home/app_events.dart';
import '../pages/details_event.page.dart';

class MapEventWidget extends StatefulWidget {
  final Function(List<EventModel>) onEventsSelected;
  final Function(List<EventModel>) onFilterChanged;

  const MapEventWidget({
    super.key,
    required this.onEventsSelected,
    required this.onFilterChanged,
  });

  @override
  _MapEventWidgetState createState() => _MapEventWidgetState();
}

class _MapEventWidgetState extends State<MapEventWidget> {
  final MapController _mapController = MapController();
  static const double _mapHeight = 440;
  List<EventModel> _displayedEvents = [];
  Map<int, EventModel> _eventMap = {}; // ✅ Stockage des événements par ID

  @override
  void initState() {
    super.initState();
    final eventBloc = context.read<EventBloc>();

    // ✅ Charger tous les événements pour la carte
    eventBloc.add(const LoadEventEvent(usePagination: false));

    // ✅ Mise à jour de la liste visible lors du déplacement de la carte
    _mapController.mapEventStream.listen((_) {
      _updateVisibleEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        if (state is EventLoadingState) {
          return const SizedBox(
            height: _mapHeight,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is EventLoadedState) {
          _displayedEvents = state.events;
          _eventMap = {for (var event in _displayedEvents) event.id: event};
        }

        if (_displayedEvents.isEmpty) {
          return const SizedBox(
            height: _mapHeight,
            child: Center(child: Text("Aucun événement trouvé")),
          );
        }

        final markers = _displayedEvents.map((event) {
          return Marker(
            key: ValueKey(event.id),
            point: LatLng(event.latitude, event.longitude),
            width: 100,
            height: 55,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    _showEventDetails(event);
                  },
                  child: const Icon(Icons.location_pin,
                      color: Colors.red, size: 36),
                ),
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 80),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      event.title,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList();

        final LatLng center =
            markers.isNotEmpty ? markers.first.point : LatLng(48.8566, 2.3522);

        return Stack(
          children: [
            Container(
              height: _mapHeight,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 16.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                    interactiveFlags: InteractiveFlag.all,
                    onMapEvent: (_) => _updateVisibleEvents(),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    ),

                    // ✅ Ajout des zones carrées
                    PolygonLayer(
                      polygons: [
                        // 🔵 Zone 1 (Now Lowered)
                        _buildZonePolygon(
                          Colors.blue.withOpacity(0.4),
                          [
                            LatLng(50.3288, 3.5125), // Moved from 50.3308
                            LatLng(50.3288, 3.5170), // Moved from 50.3308
                            LatLng(50.3272, 3.5170), // Moved from 50.3292
                            LatLng(50.3272, 3.5125), // Moved from 50.3292
                          ],
                        ),

                        // 🟢 Zone 2 (Now Lowered)
                        _buildZonePolygon(
                          Colors.green.withOpacity(0.4),
                          [
                            LatLng(50.3272, 3.5125), // Moved from 50.3292
                            LatLng(50.3272, 3.5170), // Moved from 50.3292
                            LatLng(50.3256, 3.5170), // Moved from 50.3276
                            LatLng(50.3256, 3.5125), // Moved from 50.3276
                          ],
                        ),

                        // 🔴 Zone 3 (Now Lowered)
                        _buildZonePolygon(
                          Colors.red.withOpacity(0.4),
                          [
                            LatLng(50.3256, 3.5125), // Moved from 50.3276
                            LatLng(50.3256, 3.5170), // Moved from 50.3276
                            LatLng(50.3240, 3.5170), // Moved from 50.3260
                            LatLng(50.3240, 3.5125), // Moved from 50.3260
                          ],
                        ),
                      ],
                    ),

                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 45,
                        size: const Size(40, 40),
                        markers: markers,
                        onClusterTap: (clusterNode) {
                          _showClusterEvents(
                              _getClusterAndVisibleEvents(clusterNode));
                        },
                        builder: (context, markers) {
                          return Container(
                            decoration: const BoxDecoration(
                                color: Colors.blue, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                markers.length.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ✅ Boutons de zoom
            Positioned(
              bottom: 10,
              right: 10,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: "zoomIn",
                    mini: true,
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: "zoomOut",
                    mini: true,
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    },
                    child: const Icon(Icons.remove, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// 📌 Créer une zone polygonale
  Polygon _buildZonePolygon(Color color, List<LatLng> points) {
    return Polygon(
      points: points,
      color: color,
      borderColor: Colors.black,
      borderStrokeWidth: 2,
      isFilled: true,
    );
  }

  /// 🔍 **Filtrage des événements visibles**
  void _updateVisibleEvents() {
    if (!mounted) return;

    final bounds = _mapController.camera.visibleBounds;
    final visibleEvents = _displayedEvents.where((event) {
      return bounds.contains(LatLng(event.latitude, event.longitude));
    }).toList();

    setState(() {
      _displayedEvents = visibleEvents;
    });

    widget.onFilterChanged(visibleEvents);
    print("📌 Événements visibles après mouvement : ${visibleEvents.length}");
  }

  /// 📌 **Afficher la liste des événements dans un cluster et sous-cluster**
  List<EventModel> _getClusterAndVisibleEvents(MarkerClusterNode clusterNode) {
    Set<EventModel> clusterEvents = {};

    // 1️⃣ Récupérer les événements qui sont DANS le cluster cliqué
    for (var marker in clusterNode.children.whereType<Marker>()) {
      int? eventId = marker.key is ValueKey<int>
          ? (marker.key as ValueKey<int>).value
          : null;
      if (eventId != null && _eventMap.containsKey(eventId)) {
        clusterEvents.add(_eventMap[eventId]!);
      }
    }

    print(
        "📌 Événements du cluster cliqué : ${clusterEvents.map((e) => e.id).toList()}");

    // 2️⃣ Ajout des événements VISIBLES qui peuvent faire partie du sous-cluster
    final bounds = _mapController.camera.visibleBounds;
    final visibleEvents = _displayedEvents.where((event) {
      return bounds.contains(LatLng(event.latitude, event.longitude));
    }).toList();

    clusterEvents.addAll(visibleEvents);

    print(
        "📌 Événements après ajout des sous-clusters visibles : ${clusterEvents.map((e) => e.id).toList()}");

    return clusterEvents.toList();
  }

  void _showEventDetails(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailEvent(eventId: event.id)),
    );
  }

  void _showClusterEvents(List<EventModel> events) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: FutureBuilder<String?>(
                  future: _getLocalImagePath(event.imageName),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        width: 50,
                        height: 50,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError ||
                        snapshot.data == null ||
                        !File(snapshot.data!).existsSync()) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image,
                            size: 30, color: Colors.red),
                      );
                    } else {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(snapshot.data!),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                  },
                ),
                title: Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle:
                    Text("📍 ${event.locationName} - Zone: ${event.zone}"),
                onTap: () {
                  Navigator.pop(context);
                  _showEventDetails(event);
                },
              ),
            );
          },
        );
      },
    );
  }

  /// 📂 **Récupérer le chemin d'une image locale**
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
}

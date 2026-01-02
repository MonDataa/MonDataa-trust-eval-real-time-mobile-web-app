import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'appbar_item.widget.dart';

class MapPickerScreen extends StatefulWidget {
  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng selectedLocation = LatLng(50.3278, 3.5138); // Default location
  final MapController _mapController = MapController();
  double _currentZoom = 18.0; // Initial zoom level

  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
      _mapController.move(selectedLocation, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 1;
      _mapController.move(selectedLocation, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Sélectionner un emplacement"),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: selectedLocation,
              zoom: _currentZoom,
              onTap: (tapPosition, point) {
                setState(() {
                  selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),

              // 📌 Ajout des zones sous forme de polygones
              PolygonLayer(
                polygons: [
                  _buildZonePolygon(
                    "Zone Nord",
                    Colors.blue.withOpacity(0.4),
                    [
                      LatLng(50.3296, 3.5138),
                      LatLng(50.3296, 3.5156),
                      LatLng(50.3288, 3.5156),
                      LatLng(50.3288, 3.5138),
                    ],
                  ),
                  _buildZonePolygon(
                    "Zone Centre",
                    Colors.green.withOpacity(0.4),
                    [
                      LatLng(50.3288, 3.5138),
                      LatLng(50.3288, 3.5156),
                      LatLng(50.3278, 3.5156),
                      LatLng(50.3278, 3.5138),
                    ],
                  ),
                  _buildZonePolygon(
                    "Zone Sud",
                    Colors.red.withOpacity(0.4),
                    [
                      LatLng(50.3278, 3.5138),
                      LatLng(50.3278, 3.5156),
                      LatLng(50.3268, 3.5156),
                      LatLng(50.3268, 3.5138),
                    ],
                  ),
                ],
              ),

              // 📌 Ajout du marqueur
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: selectedLocation,
                    child: const Icon(Icons.location_pin,
                        color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),

          // 📌 Zoom Buttons
          Positioned(
            bottom: 90,
            left: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoomIn",
                  mini: true,
                  backgroundColor: Colors.blue,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoomOut",
                  mini: true,
                  backgroundColor: Colors.blue,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
              ],
            ),
          ),

          // 📌 Confirm Button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: "confirm",
              backgroundColor: Colors.purple[100],
              onPressed: () {
                Navigator.pop(context, selectedLocation);
              },
              child: const Icon(Icons.check, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  /// 📌 Fonction pour créer une zone sous forme de polygone
  Polygon _buildZonePolygon(String name, Color color, List<LatLng> points) {
    return Polygon(
      points: points,
      color: color,
      borderColor: Colors.black,
      borderStrokeWidth: 2,
      isFilled: true,
    );
  }
}

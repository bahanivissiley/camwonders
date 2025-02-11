import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

const String apiKey = "5b3ce3597851110001cf6248b61e34e52a804a1681656eec996f618b";

class MapScreen extends StatefulWidget {
  final double userLong;
  final double userLat;
  final double endLong;
  final double endLat;
  final double distanceKm;

  const MapScreen({super.key, required this.userLong, required this.userLat, required this.endLong, required this.endLat, required this.distanceKm});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> points = [];

  MapController mapController = MapController();


  @override
  void initState() {
    super.initState();
    getRoute();
  }

  Future<void> getRoute() async {
    final url = Uri.parse(
        "https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${widget.userLong},${widget.userLat}&end=${widget.endLong},${widget.endLat}");

    final response = await http.get(url);


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["features"] == null || data["features"].isEmpty) {
        return;
      }

      // Récupérer les coordonnées de l'itinéraire
      final coordinates = data["features"][0]["geometry"]["coordinates"];

      // Récupérer la distance totale (en mètres)
      final double distanceMeters = data["features"][0]["properties"]["segments"][0]["distance"];


      setState(() {
        points = coordinates
            .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
            .toList();
      });
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Itinairaire")),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: LatLng(widget.userLat, widget.userLong),
          initialZoom: 13,
          interactionOptions:
          const InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom),
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: points,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(widget.userLat, widget.userLong),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40.0,
                ),
              ),
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(widget.endLat, widget.endLong),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 40.0,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: getRoute,
        label: Text("Distance: ${widget.distanceKm.toStringAsFixed(2)} km"),
        icon: const Icon(Icons.route),
      ),
    );
  }
}


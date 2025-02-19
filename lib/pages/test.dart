import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';

const String apiKey = "5b3ce3597851110001cf6248b61e34e52a804a1681656eec996f618b";

class MapScreen extends StatefulWidget {
  final double endLong;
  final double endLat;

  const MapScreen({super.key, required this.endLong, required this.endLat});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> points = [];
  MapController mapController = MapController();
  Position? _currentPosition;
  double _distanceKm = 0.0;
  String _eta = "...";
  bool _voiceEnabled = true;
  final FlutterTts flutterTts = FlutterTts();
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {});

    _getRoute();

    // Suivi en temps réel
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getRoute();
    });
  }

  Future<void> _getRoute() async {
    if (_currentPosition == null) return;

    final url = Uri.parse(
      "https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey"
          "&start=${_currentPosition!.longitude},${_currentPosition!.latitude}"
          "&end=${widget.endLong},${widget.endLat}",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["features"] == null || data["features"].isEmpty) return;

      final coordinates = data["features"][0]["geometry"]["coordinates"];
      final double distanceMeters = data["features"][0]["properties"]["segments"][0]["distance"];
      final double durationSeconds = data["features"][0]["properties"]["segments"][0]["duration"];
      final List<dynamic> steps = data["features"][0]["properties"]["segments"][0]["steps"];

      setState(() {
        points = coordinates.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();
        _distanceKm = distanceMeters / 1000;
        _eta = "${(durationSeconds / 60).toStringAsFixed(0)} min";
      });

    }
  }



  void _shareRoute() {
    final String shareText =
        "🚗 Itinéraire : \n- Distance : ${_distanceKm.toStringAsFixed(2)} km\n- Temps estimé : $_eta\n- Destination : https://www.google.com/maps/search/?api=1&query=${widget.endLat},${widget.endLong}";

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Navigation en temps réel"),
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          initialZoom: 13,
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
                strokeWidth: 5.0,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 50.0,
                height: 50.0,
                point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                child: const Icon(Icons.navigation, color: Colors.red, size: 40.0),
              ),
              Marker(
                width: 50.0,
                height: 50.0,
                point: LatLng(widget.endLat, widget.endLong),
                child: const Icon(Icons.location_on, color: Colors.green, size: 40.0),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _shareRoute,
            label: const Text("Partager", style: TextStyle(color: Colors.white),),
            icon: const Icon(Icons.share),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: _getRoute,
            label: Text("Distance: ${_distanceKm.toStringAsFixed(2)} km | Estimation temps: $_eta", style: TextStyle(color: Colors.white),),
            icon: const Icon(Icons.route),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchAndPickOSM extends StatefulWidget {
  const SearchAndPickOSM({super.key});

  @override
  State<SearchAndPickOSM> createState() => _SearchAndPickOSMState();
}

class _SearchAndPickOSMState extends State<SearchAndPickOSM> {
  final MapController _mapController = MapController();
  latlong.LatLng _selectedLocation = const latlong.LatLng(0.0, 0.0);
  final TextEditingController _searchController = TextEditingController();
  String _locationName = '';

  Future<void> _searchLocation() async {
    try {
      String query = _searchController.text.trim();
      if (query.isEmpty) return;

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeQueryComponent(query)}&format=json&limit=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'EmergeBusinessApp/1.0'},
      );

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final result = data[0];
          final lat = double.parse(result['lat']);
          final lon = double.parse(result['lon']);
          setState(() {
            _selectedLocation = latlong.LatLng(lat, lon);
            _locationName = result['display_name'] ?? query;
          });
          _mapController.move(_selectedLocation, 15);
        } else {
          _showSnackBar('Location not found');
        }
      } else {
        _showSnackBar('Error searching location');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _onMapTap(TapPosition tapPosition, latlong.LatLng position) {
    setState(() {
      _selectedLocation = position;
      _locationName = 'Lat: ${position.latitude}, Lng: ${position.longitude}';
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Shop Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, {
                'latitude': _selectedLocation.latitude,
                'longitude': _selectedLocation.longitude,
                'locationName': _locationName,
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Location',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchLocation(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const latlong.LatLng(0.0, 0.0),
                initialZoom: 2,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
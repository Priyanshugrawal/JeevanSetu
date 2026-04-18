import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapDashboard extends StatefulWidget {
  const MapDashboard({super.key});
  @override
  State<MapDashboard> createState() => _MapDashboardState();
}

class _MapDashboardState extends State<MapDashboard> {
  List<Marker> _markers = [];
  List<CircleMarker> _circles = [];
  bool _loading = true;

  static const LatLng _raipur = LatLng(21.2514, 81.6296);

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _loading = true);
    final snap = await FirebaseFirestore.instance
        .collection('reports')
        .get();

    List<Marker> markers = [];
    List<CircleMarker> circles = [];

    for (var doc in snap.docs) {
      final data = doc.data();
      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;

      final priority = data['priority'] as String? ?? 'LOW';
      final color = priority == 'HIGH'
          ? Colors.red
          : priority == 'MEDIUM'
              ? Colors.orange
              : Colors.green;

      final pos = LatLng(lat, lng);

      markers.add(Marker(
        point: pos,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showInfo(context, data, priority),
          child: Icon(Icons.location_pin, color: color, size: 40),
        ),
      ));

      circles.add(CircleMarker(
        point: pos,
        radius: priority == 'HIGH' ? 800 : priority == 'MEDIUM' ? 500 : 300,
        useRadiusInMeter: true,
        color: color.withOpacity(0.18),
        borderColor: color.withOpacity(0.5),
        borderStrokeWidth: 1,
      ));
    }

    setState(() {
      _markers = markers;
      _circles = circles;
      _loading = false;
    });
  }

  void _showInfo(BuildContext context, Map<String, dynamic> data, String priority) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: priority == 'HIGH' ? Colors.red.shade100
                      : priority == 'MEDIUM' ? Colors.orange.shade100
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(priority,
                  style: TextStyle(
                    color: priority == 'HIGH' ? Colors.red.shade800
                        : priority == 'MEDIUM' ? Colors.orange.shade800
                        : Colors.green.shade800,
                    fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Text(data['problemType'] ?? 'Report',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 10),
            Text(data['description'] ?? '',
              style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Incident Map'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _raipur,
                    initialZoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.smart_resource_app',
                    ),
                    CircleLayer(circles: _circles),
                    MarkerLayer(markers: _markers),
                  ],
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(
                        color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _legendItem(Colors.red,    'HIGH priority'),
                        _legendItem(Colors.orange, 'MEDIUM priority'),
                        _legendItem(Colors.green,  'LOW priority'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Container(width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ]),
    );
  }
}
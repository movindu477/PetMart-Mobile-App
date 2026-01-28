import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMapSection extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String city;

  const LocationMapSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.city,
  });

  @override
  State<LocationMapSection> createState() => _LocationMapSectionState();
}

class _LocationMapSectionState extends State<LocationMapSection> {
  GoogleMapController? _mapController;

  @override
  void didUpdateWidget(covariant LocationMapSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_mapController != null &&
        (oldWidget.latitude != widget.latitude ||
            oldWidget.longitude != widget.longitude)) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(widget.latitude, widget.longitude)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng userLocation = LatLng(widget.latitude, widget.longitude);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF1565C0), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Delivering to ${widget.city}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: userLocation,
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                markers: {
                  Marker(
                    markerId: const MarkerId("user_location"),
                    position: userLocation,
                    infoWindow: InfoWindow(title: widget.city),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                mapType: MapType.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

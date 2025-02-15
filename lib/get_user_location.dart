import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GetUserLocation extends StatefulWidget {
  const GetUserLocation({super.key});

  @override
  State<GetUserLocation> createState() => _GetUserLocationState();
}

class _GetUserLocationState extends State<GetUserLocation> {
  late GoogleMapController mapController;
  LatLng _currentPosition = const LatLng(37.7749, -122.4194); // Default (San Francisco)
  bool _isLocationFetched = false;

  // Function to get current location
  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLocationFetched = false;
        });
        print("Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Location permission denied.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("Location permissions are permanently denied.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLocationFetched = true;
      });

      // Move the map to the user's location
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 14.0),
      );
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  // Initialize the Google Maps Controller
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (!_isLocationFetched) {
      _getUserLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Map Location")),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 12.0,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("currentLocation"),
                  position: _currentPosition,
                  infoWindow: const InfoWindow(title: "Your Location"),
                )
              },
            ),
          ),
          ElevatedButton(
            onPressed: _getUserLocation,
            child: const Text("Get My Location"),
          ),
        ],
      ),
    );
  }
}

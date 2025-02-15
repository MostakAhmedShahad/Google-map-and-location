import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_and_location/get_user_location.dart';
  // Import your Google Map screen

class GetUserPermission extends StatefulWidget {
  const GetUserPermission({super.key});

  @override
  State<GetUserPermission> createState() => _GetUserPermissionState();
}

class _GetUserPermissionState extends State<GetUserPermission> {
  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      // Navigate to Google Map screen if permission is granted
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GetUserLocation()),
      );
    } else {
      // Show message if permission is denied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission is required to continue.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Location Permission")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "We need your location to show the map.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestLocationPermission,
              child: const Text("Allow Location"),
            ),
          ],
        ),
      ),
    );
  }
}

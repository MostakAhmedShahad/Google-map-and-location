import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:js' as js;
import 'dart:js_util' as js_util;

class GoogleMapSearch extends StatefulWidget {
  const GoogleMapSearch({super.key});

  @override
  State<GoogleMapSearch> createState() => _GoogleMapSearchState();
}

class _GoogleMapSearchState extends State<GoogleMapSearch> {
  late GoogleMapController mapController;
  TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  LatLng _currentPosition =
      const LatLng(37.7749, -122.4194); // Default location (San Francisco)
  bool _isLocationFetched = false;

  // Google API Key (replace with your actual API key)
  final String apiKey = "AlzaSy1LRK3ButIWBw8DRkCDzAjNcJw2jTTEeMg";

  // Function to fetch places using Google Places API
  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final String url =
        "https://maps.gomaps.pro/maps/api/place/autocomplete/json?input=$query&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          searchResults = data['predictions'];
        });
      } else {
        print("Error fetching places: ${response.body}");
      }
    } catch (e) {
      print("Error fetching places: $e");
    }
  }

  // Function to fetch place details and navigate to it
  Future<void> _goToPlace(String placeId) async {
    final String detailsUrl =
        "https://maps.gomaps.pro/maps/api/place/details/json?place_id=$placeId&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(detailsUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['result']['geometry']['location'];
        final double lat = location['lat'];
        final double lng = location['lng'];

        setState(() {
          _currentPosition = LatLng(lat, lng);
          searchResults = [];
          searchController.clear();
        });

        // Move the Google Map to the selected location
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0),
        );
      } else {
        print("Error fetching place details: ${response.body}");
      }
    } catch (e) {
      print("Error fetching place details: $e");
    }
  }

  // Function to get user's current location

  Future<void> _getUserLocation() async {
    if (_isLocationFetched) return; // Prevent multiple fetches

    final jsFunction = js.allowInterop((position) {
      final coords = js_util.getProperty(position, 'coords');
      final lat = js_util.getProperty(coords, 'latitude');
      final lng = js_util.getProperty(coords, 'longitude');

      setState(() {
        _currentPosition = LatLng(lat, lng);
        _isLocationFetched = true;
      });

      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0),
      );
    });

    final jsError = js.allowInterop((error) {
      print(
          "Error fetching location: ${js_util.getProperty(error, 'message')}");
    });

    // Ensure geolocation API exists
    if (js.context.hasProperty('navigator') &&
        js_util.hasProperty(js.context['navigator'], 'geolocation')) {
      js.context['navigator']['geolocation'].callMethod(
        'getCurrentPosition',
        [jsFunction, jsError],
      );
    } else {
      print("Geolocation is not supported in this browser.");
    }
  }

  // Initialize the Google Maps Controller
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Place & Navigate")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              onChanged: _searchPlaces,
              decoration: InputDecoration(
                hintText: "Search for a place...",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchResults = [];
                    });
                  },
                ),
              ),
            ),
          ),

          // Show search results
          if (searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final result = searchResults[index];
                  return ListTile(
                    title: Text(result['description']),
                    onTap: () => _goToPlace(result['place_id']),
                  );
                },
              ),
            ),

          // Google Map
          Expanded(
            flex: 2,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 12.0,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("searchedLocation"),
                  position: _currentPosition,
                  infoWindow: const InfoWindow(title: "Selected Location"),
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

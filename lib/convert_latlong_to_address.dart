import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConvertLatlongToAddress extends StatefulWidget {
  const ConvertLatlongToAddress({super.key});

  @override
  State<ConvertLatlongToAddress> createState() =>
      _ConvertLatlongToAddressState();
}

class _ConvertLatlongToAddressState extends State<ConvertLatlongToAddress> {
  String address = "Tap to fetch address";

  Future<void> fetchAddress() async {
    double latitude = 33.6992;
    double longitude = 72.9744;
    String apiKey = "AlzaSy1LRK3ButIWBw8DRkCDzAjNcJw2jTTEeMg"; // Replace with your API Key

    String url =
        "https://maps.gomaps.pro/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data["status"] == "OK") {
          String formattedAddress = data["results"][0]["formatted_address"];
          setState(() {
            address = formattedAddress;
          });
          print("Address: $formattedAddress");
        } else {
          print("No address found.");
        }
      } else {
        print("Failed to fetch address.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: fetchAddress,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                child: Center(
                  child: Text("Convert"),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(address, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

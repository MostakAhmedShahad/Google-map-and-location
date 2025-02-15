import 'package:flutter/material.dart';
import 'package:google_map_and_location/convert_latlong_to_address.dart';
import 'package:google_map_and_location/get_user_permission.dart';
import 'package:google_map_and_location/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
         
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: GetUserPermission( ),
    );
  }
}
 
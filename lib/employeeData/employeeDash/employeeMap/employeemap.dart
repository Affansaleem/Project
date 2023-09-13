import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeMap extends StatefulWidget {
  EmployeeMap({Key? key}) : super(key: key);

  @override
  _EmployeeMapState createState() => _EmployeeMapState();
}

class _EmployeeMapState extends State<EmployeeMap> {
  double? getLat;
  double? getLong;
  double? getRadius;
  double? currentLat;
  double? currentLong;
  bool locationError = false;
  final Geolocator geolocator = Geolocator();
  String address = "";

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
    checkLocationPermissionAndFetchLocation();
    loadCoordinatesFromSharedPreferences();
    display();
  }

  Future<void> loadCoordinatesFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    getLat = double.tryParse(prefs.getString('latitude') ?? '');
    getLong = double.tryParse(prefs.getString('longitude') ?? '');
    getRadius = double.tryParse(prefs.getString('radius') ?? '');
    print(getLat.toString());
    print(getLong.toString());
    print(getRadius.toString());
  }



  Future<void> checkLocationPermission() async {
    Geolocator.getServiceStatusStream().listen((status) {
      setState(() {
        locationError = status != ServiceStatus.enabled;
      });
    });
  }

  void _startGeoFencingUpdate() {
    final double? geofenceLatitude = getLat;
    final double? geofenceLongitude = getLong;
    final double? geofenceRadius = getRadius;
    double distance = Geolocator.distanceBetween(
        geofenceLatitude!, geofenceLongitude!, currentLat!, currentLong!);

    print(getLat);
    print(getLong);
    print(getRadius);
    if (distance <= geofenceRadius!) {
      print("in radius");
      inRadius();
    } else if (distance >= geofenceRadius) {
      print("out radius");

      outRadius();
    }
  }

  void display() {
    print("${getLat} ${getLong}");
  }

  Future<void> checkLocationPermissionAndFetchLocation() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      try {
        final data = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          currentLat = data.latitude;
          currentLong = data.longitude;
          locationError = false;
        });
        getAddress(currentLat, currentLong);
      } catch (e) {
        print('Error getting location: $e');
      }
    } else {
      setState(() {
        locationError = true;
      });
    }
  }

  void inRadius() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congrats'),
          content: const Text('Your Attendance Is MARKED'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void outRadius() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oh No'),
          content: const Text('Your Attendance did not get MARKED'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  getAddress(lat, long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    setState(() {
      address =
      "${placemarks[0].street!}, ${placemarks[4].street!} , ${placemarks[0].country!}";
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (locationError) {
      return AlertDialog(
        title: const Text('Turn On Location'),
        content: const Text('Please turn on your location to use this feature.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFE26142),
          elevation: 0,
          title: Row(
            children: [
              const Text("Employee"),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _startGeoFencingUpdate,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),
        body: (currentLat != null && currentLong != null)
            ? OpenStreetMapSearchAndPick(
          center: LatLong(currentLat!, currentLong!),
          onPicked: (pickedData) {
            getAddress(pickedData.latLong.latitude, pickedData.latLong.longitude);
          },
          locationPinIconColor: const Color(0xFFE26142),
          locationPinText: "${address}",
        )
            : const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}

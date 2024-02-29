import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'dart:developer';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Completer<GoogleMapController> _controller = Completer();
  Position? currentPosition;
  List<LatLng> polylineCoordinates = [];

  static const LatLng sourceLocation = LatLng(10.29733339, 123.9070278);

  @override
  void initState() {
    super.initState();
    getPolyPoints();
    _requestPermissionAndGetCurrentLocation();
  }

  _requestPermissionAndGetCurrentLocation() async {
    var permissionStatus = await Permission.location.request();
    if (permissionStatus.isGranted) {
      _getCurrentLocation();
    } else {
      // Handle the case if permission is not granted
    }
  }

  _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = position;
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyBTiF2fh1EfEbZh9VNK07KtaGV7NNQtnQs",
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(currentPosition!.latitude, currentPosition!.longitude));

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPosition != null
          ? GoogleMap(
              zoomControlsEnabled: false,
              mapType: MapType.satellite,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentPosition!.latitude, currentPosition!.longitude),
                zoom: 10,
              ),
              polylines: {
                Polyline(
                    polylineId: PolylineId("route"),
                    points: polylineCoordinates,
                    color: Colors.blueAccent,
                    width: 7)
              },
              markers: {
                Marker(
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                    markerId: MarkerId("source"),
                    position: sourceLocation),
                Marker(
                    markerId: MarkerId("currentLocation"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                    position: LatLng(
                        currentPosition!.latitude, currentPosition!.longitude))
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
//test
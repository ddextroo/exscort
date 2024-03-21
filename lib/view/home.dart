import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class Home extends StatefulWidget {
 const Home({Key? key}) : super(key: key);

 @override
 State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
 Position? currentPosition;
 List<LatLng> polylineCoordinates = [];

 static const LatLng sourceLocation = LatLng(10.29733339, 123.9070278);

 @override
 void initState() {
    super.initState();
    _requestPermissionAndGetCurrentLocation();
 }

 _requestPermissionAndGetCurrentLocation() async {
    var permissionStatus = await Permission.location.request();
    if (permissionStatus.isGranted) {
      _getCurrentLocation();
    }
 }

 _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = position;
      getPolyPoints();
    });
 }

 void getPolyPoints() async {
    if (currentPosition != null) {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          "AIzaSyC5EK2yWGZ7Z4dOgbyAsGWPLtwVDMCIj88",
          PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
          PointLatLng(currentPosition!.latitude, currentPosition!.longitude));

      if (result.points.isNotEmpty) {
        setState(() {
          polylineCoordinates = result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
        });
      }
    }
 }

 @override
 Widget build(BuildContext context) {
    return Scaffold(
      body: currentPosition != null
          ? GoogleMap(
              zoomControlsEnabled: true,
              mapType: MapType.satellite,
              initialCameraPosition: CameraPosition(
                target: LatLng(currentPosition!.latitude, currentPosition!.longitude),
                zoom: 20,
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
                    position: LatLng(currentPosition!.latitude, currentPosition!.longitude)),
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
 }
}

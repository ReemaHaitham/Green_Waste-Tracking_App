import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

//stateful used for daynamic data each refesh take the new data and make changes
class comp_tracking_order extends StatefulWidget {
  //tracking_location constractor take these argument when it's called
  const comp_tracking_order(
      {super.key, required this.orderlat,required this.orderlong, required this.sp_name});
  final double orderlat;
  final double orderlong;
  final String sp_name;
  @override
  State<comp_tracking_order> createState() => MapState();
}

class MapState extends State<comp_tracking_order> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static  LatLng sourceLocation = LatLng(0, 0);
  static  LatLng destinationLocation= LatLng(0, 0);
  final Completer<GoogleMapController> _controller = Completer();
  //creating a line for to connect the source and the distenation
  List<LatLng> polylineCoordinates = [];

  //return source and destination markers latlong from firebase
  Future locations(order_lat,order_long, sp_name) async {
    //return source
    final latitude = order_lat;
    final longitude = order_long;
    sourceLocation = LatLng(latitude, longitude);
    //return
    await firestore
        .collection("serviceProviders")
        .where("SP_name", isEqualTo: sp_name)
        .get()
        .then((result) => result.docs.forEach((element) {
      final latitude = element["latitude"];
      final longitude = element["longitude"];
      destinationLocation = LatLng(latitude, longitude);
    }));

    setState(() {});
    getPolypoints();
  } //location funstion
  LocationData? currentLocation;
  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
          (location) {
        currentLocation = location;
      },
    );
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen(
          (newLoc) {
        currentLocation = newLoc;
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
        setState(() {});
      },
    );
  }
  //get the distance between source and destination markers
  void getPolypoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyALT6SII0CWZHKA9w-iZuaMxK8l7AsB4hc',
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
      //if current location == destination pop up the btn of conform delivry
    );
    if (result.points.isNotEmpty) {
      result.points.forEach(
            (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
    getCurrentLocation();
  } //end of getPolypoints

  @override
  void initState() {
    var order_lat = widget.orderlat;
    var order_long = widget.orderlong;
    var sp_name = widget.sp_name;
    locations(order_lat,order_long, sp_name); //it takes tow arguments the company email and the servies provider name  values from the orderview class
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      appBar: AppBar(
        title: Text('Live Location'),
        backgroundColor: Colors.lightGreen[300],
      ),
      //loading page before diplaying the map
      body:sourceLocation == null || sourceLocation==LatLng(0, 0)
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Loading...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
          ],
        ),
      )
          :GoogleMap(
        initialCameraPosition: CameraPosition(
          zoom: 13.5,
          target: sourceLocation,
        ),
        markers: <Marker>{
          Marker(
            markerId: MarkerId('source'),
            position: LatLng(sourceLocation.latitude, sourceLocation.longitude),
            infoWindow: InfoWindow(
              title: "Source",
            ),
          ),
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: LatLng(currentLocation?.latitude??0, currentLocation?.longitude??0),
          ),
          Marker(
            markerId: MarkerId("Destination"),
            position: LatLng(destinationLocation.latitude, destinationLocation.longitude),
            infoWindow: InfoWindow(
              title: "Destination",
            ),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        polylines: Set<Polyline>.of(
          <Polyline>[
            Polyline(
              polylineId: PolylineId("Route_Polylines"),
              visible: true,
              points: polylineCoordinates,
              width: 5,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}
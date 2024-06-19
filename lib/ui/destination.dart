import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gap/gap.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map/directions.dart';
import 'package:google_map/firebaseauth.dart';
import 'package:google_map/mapkey.dart';
import 'package:google_map/request_assistant.dart';
import 'package:google_map/ui/login.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Destination extends StatefulWidget {
  const Destination({super.key});

  @override
  State<Destination> createState() => MapSampleState();
}

class MapSampleState extends State<Destination> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController? newGoogleMapController;
  LatLng? picklocation;
  loc.Location location = loc.Location();
  String? _address;
  String? _fromAddress;
  String? _toAddress;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220;
  double watingResponcefromDriverContainerHeight = 0;
  double assignedDriverInfoHeight = 0;
  Position? userCurrentPositon;
  var geolocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottompaddingOfMap = 0;

  List<LatLng> pLineCoordinateList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  bool activeNearbyDriverKeyLoaded = true;

  BitmapDescriptor? activeNearbyIcon;

  // final _fromController = TextEditingController();
  // final _toController = TextEditingController();

  locatateUserPosition() async {
    Position cPostion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userCurrentPositon = cPostion;
    });

    LatLng latLngPostion =
        LatLng(userCurrentPositon!.latitude, userCurrentPositon!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPostion, zoom: 15);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanReadableAddress = await searchAddressForGeogragraphCordinates(
        userCurrentPositon!, context);
    print("this is our address = " + humanReadableAddress);
    setState(() {
      _fromAddress = humanReadableAddress;
    });
  }

  getAddressFromLatLng(LatLng latLng) async {
    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          googleMapApiKey: mapKey);
      return data.address;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  @override
  void initState() {
    super.initState();
    _address = "Current Location";
    checkIfLocationPermissionAllowed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Destination'),
          actions: [
            IconButton(
                onPressed: () async {
                  await AuthService.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const Login(),
                    ),
                    (route) => true,
                  );
                },
                icon: const Icon(Icons.logout))
          ],
        ),
        body: SafeArea(
          child: Stack(children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              markers: markerSet,
              circles: circleSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                setState(() {});

                locatateUserPosition();
              },
              onCameraMove: (CameraPosition? position) {
                if (picklocation != position!.target) {
                  setState(() {
                    picklocation = position.target;
                  });
                }
              },
              onCameraIdle: () async {
                String toAddress = await getAddressFromLatLng(picklocation!);
                setState(() {
                  _toAddress = toAddress;
                });
                drawPolyline();
              },
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: Image.asset(
                  "assets/placeholder.png",
                  height: 45,
                  width: 45,
                ),
              ),
            ),
            Positioned(
                top: 40,
                right: 20,
                left: 20,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 10,
                      ),
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(),
                          color: Colors.white),
                      child: Text(
                        "From: ${_toAddress.toString()}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 10,
                      ),
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(),
                          color: Colors.white),
                      child: Text(
                        "To: ${_toAddress ?? "Select a location on the map"}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                )),
          ]),
        ),
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  drawPolyline();
                },
                child: const Text(
                  "Show route",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Gap(10),
              ElevatedButton(
                onPressed: () async {
                  String driverToken =
                      "fRH9MoLRRZKk8wwrtyqR9n:APA91bE7CCSGdbRG956CYplZgKNixKnXNihhLrI5Ch9vbqk9jcACJ_zaaTYqUyC9sj9omMnK9d91SSN9wfJmLU1dSqUfRfXKTwv_xcZyb1R1BahIsy8_WPU2YK3llLPgPNj3qZOASXYL";

                  // Create a notification request
                  var request = {
                    'to': driverToken,
                    'data': {
                      'title': 'Ride Request',
                      'body': 'You have a new ride request!',
                    },
                  };

                  String privateKey =
                      "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQD1tiUrgBe1Xecg\ncMNYghhYr8JSGzXxLUsIugpW4iyocpI287cFBBkoCRDZQcPVS0tWn6kqaTgdBi78\n8d6rah3qG5lImcEUwb0UjXtnYQ+nbkEyINDP/VXTGODOawABBBP6s4hsjdV4UCWx\nMPWRYuCuiO/iozbMxzQ5BGC8IY4kzeV1RkiaNC2u+ZkyzxYR4R07W3BDxw42BKHM\n7UJ/MOQIZim3qsYv60p1ewXYPR79o45bj5R3kjbQb/J6Nzwwz/TQ6Uuixio037h3\nNd7mA9Huuox7+8Kr2+vxtcT+neSZ6ATcxDOh5tJJWovTwg+6AzKCLoXgFkW4p3/o\n5p6cBVZpAgMBAAECggEAIaKmLUbtopWQ1sSuQ7wbWm3vleRvr+zZVqp7poUeQ+OF\n1yE/A+AZvtHu4oQO1hs73Eci6yatgxueQbYCcJ39gQH3gRQQdaedGzvQPB3x/KN/\n0pLiGCFqfD6YQj7XffbG8rdc4i9QR5YBHY5sL1NvxQoDJ0KHH+UtEEO50kcYTuUz\n66Sje0golnJhawTqeeAvwYL7+2xADNNvDv3HBxbZwcS3YBFfYeIxmx8nOb8MYcPK\nWwHG184S79TlaToO34m8F6/wF/ctZD5yFEY72hvSbgI2llh9g/+Z2J3BkQy1IlvC\nXLjTC5hwaaY0G0BecaiNAn4eL2S7ryQbQxRc8Et8WQKBgQD908hHgptBQEaxSRZA\nSDr6fN8syH0Sb/3Z4UcP3kgdlSJedSgfxvqWPntyFCsm4SZYFd2lVlwqhIR8EoB1\nxTenOdLtjiorLwDjsAe2Uri+o4Eux1fsQix1ZLIf0+qwyLdXsl6sBfXgJXjTedlg\nhg5wrzp5MGDTgn9u7yZpYmCfAwKBgQD30JQdl3vluAarpPr5s1p9Uue0Pdr1QXwt\nuPJUWgMPhWZYntkvUx0BX/jydWGFpHIPjjpk9F2OzQS1mQ6kXFIZAaztGjQ9s/qK\nDU+spWm52ZP6LW2HfTqRWUzwDv5vcdGOnnuHEINjkzpgell71qyZyagbcY039wrV\nqhJjn7YzIwKBgQCzAwWgyU/NeRNiPPVgaJCP0DllUBBFTI5vdx2y50Vc96zBiUa/\nAooAJBjTn72/MdLlFKa40Gs34TW+ex318R0K5xEHUNgUlJW//omx4C1C5fVZlGVB\nznmkYVvubnp6K1SCmN2D3MBHUKYiHzFbja/pcOuARMpE4SgWiLtCX4tdGQKBgQCP\nRAZdFTaLl9hDYx21PfsSeNt7WEc9gp5H0KRIH8GlN3nzweHNej9KjDFf+nxmxqsq\nUw9vTdbIt74BPns4iibsTgurB3ssMOCm7wsgxIBa8W6bM6gerEcvwHC6V/DAfQyp\nZvYDH4jWCEe3fwQ8k981CWAmfX8m26tn2urGrY6oAQKBgBwqPF6R6QR1LmDubbrB\nx60OWDd5vZC+yffcLdP9/wAqt1IWiT+Be4+DMcbQyIlF76FOXO6ZjPdAx8RgTywa\n10h1/gtjlAqZ3YPPQtCKmWR1ZplAuM6/jfKsNblKqga+TIhwzD1ZLQ4a10xFY1dl\nCPPykSmPt7nL4vgKaT4K+iec\n-----END PRIVATE KEY-----\n";
                  String encodedKey = base64Encode(utf8.encode(privateKey));


                  // Send the request to the FCM server
                  await http.post(
                    Uri.parse('https://fcm.googleapis.com/fcm/send'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': encodedKey,
                    },
                    body: jsonEncode(request),
                  );

                  //For checking
                  print(request.toString());
                  print("key$encodedKey");

                  // RequestAssistant.sendnotificationfordriver(RequestAssistant.deviceRegistrationToken, RequestAssistant.userRidRequestid, context);
                },
                child: const Text(
                  "Request for Ride",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ));
  }

  drawPolyline() async {
    print("Drawing polyline...");
    List<LatLng> polylineCoordinates = [];
    polylineCoordinates.add(
        LatLng(userCurrentPositon!.latitude, userCurrentPositon!.longitude));
    polylineCoordinates.add(picklocation!);

    // just checking
    print("Polyline coordinates: $polylineCoordinates");

    Polyline polyline = Polyline(
      polylineId: const PolylineId("polyline"),
      color: Colors.blue,
      width: 5,
      points: polylineCoordinates,
    );

    // just checking
    print("Polyline created: $polyline");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        polylineSet.add(polyline);
      });

      // just checking
      print("Polyline added to set: $polylineSet");
    });
  }

  static Future<String> searchAddressForGeogragraphCordinates(
      Position position, context) async {
    String apiurl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    String humanReadableAddress = "";

    var requsestResponse = await RequestAssistant.reciveRequest(apiurl);

    if (requsestResponse != "Error occurd. Failed .No Response") {
      humanReadableAddress =
          requsestResponse["results"][0]["formatted_address"];

      Directions userPickupAddress = Directions();
      userPickupAddress.locationLatitude = position.latitude;
      userPickupAddress.locationLongitude = position.longitude;
      userPickupAddress.locationName = humanReadableAddress;

// Provider.of<Appinfo>(context,listen:false).updatePickUpLocationAddress(userPickupAddress);
    }
    return humanReadableAddress;
  }
}

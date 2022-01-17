import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:projeto_empresa/object/LocationReturn.dart';

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  String endereco = "Selecione o local";
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController enderecoController = new TextEditingController();
  Position position;
  Marker location;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-26.915451, -48.663483),
    zoom: 14.4746,
  );

  @override
  void initState() {}

  Future<void> getPosition() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        GoogleMap(
          mapType: MapType.hybrid,
          markers: {if (location != null) location},
          onTap: _addMarker,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
        Positioned(
          top: 80.0,
          right: 15.0,
          left: 15.0,
          child:
          Container(
            height: 58.0,
            width: double.infinity,
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Flexible(
                  child: TextField(
                    keyboardType: TextInputType.text,
                    controller: enderecoController,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          var addresses = await locationFromAddress(enderecoController.text);
                          var first = addresses.first;
                          LatLng pos = new LatLng(first.latitude,first.longitude);
                          _addMarker(pos);
                        },
                      ),
                    ),

                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0), color: Colors.white),
          ),
        )
      ],
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          LocationReturn.endereco = this.enderecoController.text;
          LocationReturn.latitude = location.position.latitude;
          LocationReturn.longitude = location.position.longitude;
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _addMarker(LatLng pos) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(pos.latitude, pos.longitude);

    Placemark place = placemarks[0];
    
    setState(() {
      location = Marker(
        markerId: const MarkerId('location'),
        infoWindow: const InfoWindow(title: 'location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: pos,
      );
    });
    endereco = "${place.street}, ${place.name} - ${place.country}";
    this.enderecoController.text = endereco;
    //print((Geolocator.distanceBetween(pos.latitude, pos.longitude, -26.926416, -48.700499)/1000).round());
  }
}

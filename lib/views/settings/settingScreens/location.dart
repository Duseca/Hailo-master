import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/common.dart';
import '../../../../core/constants/colors.dart';
import '../../../controller/location_controller.dart';

class Location extends StatelessWidget {
  const Location({super.key});

  static const double lat = 51.509865;
  static const double long = -0.118092;
  static const CameraPosition _initialCameraPosition = CameraPosition(target: LatLng(lat, long), zoom: 15);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(
        init: LocationController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: kPrimaryColor,
                ),
                onPressed: Get.back,
              ),
              title: Text(
                'Location Settings',
                style: fontBody(fontSize: 24, fontWeight: FontWeight.w500),
              ),
            ),
            body: Column(children: [
              const SizedBox(
                height: 34,
              ),
              SizedBox(
                height: 172,
                child: GoogleMap(
                  mapType: MapType.normal,
                  myLocationButtonEnabled: false,
                  initialCameraPosition: _initialCameraPosition,
                  onMapCreated: (GoogleMapController gmController) {
                    controller.googleMapController.complete(gmController);
                  },
                ),
              ),
              const SizedBox(
                height: 34,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 51,
                ),
                child: Row(children: [
                  Checkbox(
                    value: controller.yes,
                    onChanged: (val) => controller.check(),
                    checkColor: kWhiteColor,
                    activeColor: kPrimaryColor,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(
                    'Use my phones location',
                    style: fontBody(fontSize: 14, fontWeight: FontWeight.w400, fontColor: const Color(0xff898A8D)),
                  )
                ]),
              ),
              const SizedBox(
                height: 107,
              ),
              Container(
                height: 50,
                width: 194,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: kPrimaryColor),
                child: Center(
                    child: Text(
                  'Save',
                  style: fontBody(fontSize: 18, fontWeight: FontWeight.w500, fontColor: kWhiteColor),
                )),
              )
            ]),
          );
        });
  }
}

Future<Position> mylocation() async {
  bool yourlocation;
  LocationPermission permission;

  yourlocation = await Geolocator.isLocationServiceEnabled();
  if (!yourlocation) {
    return Future.error('Location Service is disabled');
  }
  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location Permission  Denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location Permanently Denied');
  }

  Position position = await Geolocator.getCurrentPosition();
  return position;
}

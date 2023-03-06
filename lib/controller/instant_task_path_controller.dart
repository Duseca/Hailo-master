import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_maps_widget/google_maps_widget.dart';

import '../core/constants/collections.dart';

class InstantTaskPathController extends GetxController {
  bool loaded = false;

  LatLng dLatLang = const LatLng(0, 0);
  final mapsWidgetController = GlobalKey<GoogleMapsWidgetState>();

  getSourceLocation(uid) async {
    DocumentSnapshot sdata = await jobsInstantCollection.doc(uid).get();

    dLatLang = LatLng(sdata['position'].latitude, sdata['position'].longitude);

    loaded = true;
    update();
  }

  @override
  void onInit() {
   // mapsWidgetController.currentState!.setSourceLatLng(dLatLang);
    super.onInit();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hailo/core/constants/collections.dart';

class SplashController extends GetxController {
  fetchAuth() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser == null ? "" : auth.currentUser!.uid;

    Future.delayed(const Duration(seconds: 1), () async {
      if (uid.isEmpty) {
        Get.offNamed("/login");
        return;
      }

      DocumentSnapshot documentSnapshot = await usersCollection.doc(uid).get();
      if (!documentSnapshot.exists) {
        await FirebaseAuth.instance.signOut();
        Get.offNamed("/login");
        return;
      }

      Get.offNamed("/root", parameters: {"uid": uid});
    });
  }

  @override
  void onInit() {
    fetchAuth();
    super.onInit();
  }
}

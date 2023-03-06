import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../core/constants/collections.dart';
import '../views/tabs/createtask_tab.dart';
import '../views/tabs/home_tab.dart';
import '../views/tabs/messages_tab.dart';
import '../views/tabs/schedules_tab.dart';

class RootController extends GetxController {
  String? uid = Get.parameters["uid"];
  String? cid = Get.parameters["cid"];
  RxInt currentTab = 0.obs;
  List bodyWidgets = [];
  late int countTask;

  changeTab(int index) {
    currentTab.value = index;
  }

  @override
  void onReady() async {
    /*  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.getToken().then((messageToken) async {
      await usersCollection.doc(uid).update({
        "messageToken": messageToken,
      });
    });*/

    super.onReady();
  }

  @override
  void onInit() async {
    bodyWidgets = [
      HomeTab(
        uid: uid!,
      ),
      CreateTaskTab(
        uid: uid!,
      ),
      SchedulesTab(
        uid: uid!,
      ),
      MessagesTab(
        uid: uid!,
      ),
    ];
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.getToken().then((messageToken) async {
      await usersCollection.doc(uid).update({
        "messageToken": messageToken,
      });
    });

    super.onInit();
  }
}

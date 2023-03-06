import 'package:get/get.dart';
import 'package:hailo/controller/chat_controller.dart';
import 'package:hailo/controller/job_page_controller.dart';
import 'package:hailo/controller/longterm_controller.dart';
import 'package:hailo/controller/profile_controller.dart';
import '../controller/login_controller.dart';
import '../controller/root_controller.dart';
import '../controller/signup_controller.dart';
import '../controller/splash_controller.dart';
import '../controller/supportChat_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashController());
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignupController());
  }
}

class LongTermBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LongTermController());
  }
}

class RootBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RootController());
  }
}

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatsController());
  }
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController());
  }
}


class JobPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => JobPageController());
  }
}


class SupportChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => supportChatController());
  }
}


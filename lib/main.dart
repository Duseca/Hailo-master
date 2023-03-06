import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:hailo/core/common.dart';
import 'package:hailo/core/constants/colors.dart';
import 'package:hailo/core/constants/routes.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDNgAGDEKX2CH5QS8nR43QOT1R6XegSkT8",
            appId: "1:890429033978:ios:b571386eed03f8246b2843",
            messagingSenderId: "890429033978",
            projectId: "hailo-a246d"));
  } else {
    await Firebase.initializeApp();
  }  await FirebaseAppCheck.instance.activate();
  // Stripe.publishableKey = "pk_test_51KpK8bCfPMYKQLpFghVq7ZHBXngJgYlL3RFdzXpPtMdSYCwGOPsm6ALbzwOOjL20YTeZIlm0O2WpI6Wk0VKAKZgY00ZCpVDehF";
  Stripe.publishableKey =
      "pk_test_51InumCJNs8MZJzppfyR24EbzNugzhhMjQuLFFgbPVLFeSm7DUNnuNZfspNa4HaGmssA13mP39eH7EkbgqznSAbCd00AdfaFS6x";
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Get.deviceLocale, //for setting localization strings
        fallbackLocale: const Locale('en', 'US'),
        title: 'Hailo',

        theme: ThemeData(
          scaffoldBackgroundColor: kWhiteColor,
          appBarTheme: AppBarTheme(
            backgroundColor: kWhiteColor,
            elevation: 0,
            iconTheme: const IconThemeData(color: kBlackColor),
            titleTextStyle: fontBody(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
        initialRoute: "/",
        getPages: Routes.all,
      );
    });
  }
}

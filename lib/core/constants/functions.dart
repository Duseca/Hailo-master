

import 'package:cloud_functions/cloud_functions.dart';

HttpsCallable sendNotificationCareTaker=FirebaseFunctions.instance.httpsCallable("sendNotificationCareTaker");
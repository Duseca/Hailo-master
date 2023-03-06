import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/colors.dart';

void errorDialog({required String title, required String msg}) {
  Get.dialog(
    AlertDialog(
      title: Text(
        title,
        style: const TextStyle(color: kPrimaryColor),
      ),
      content: Text(
        msg,
        textAlign: TextAlign.left,
      ),
      actions: [
        TextButton(
          child: const Text(
            "Ok",
            style: TextStyle(color: kPrimaryColor),
          ),
          onPressed: () => Get.back(),
        ),
      ],
    ),
  );
}

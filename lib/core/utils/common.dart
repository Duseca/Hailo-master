import 'package:flutter/material.dart';

import '../constants/colors.dart';

customProgressIndicator() => const Center(
      child: CircularProgressIndicator.adaptive(
        strokeWidth: 4,
        valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
      ),
    );

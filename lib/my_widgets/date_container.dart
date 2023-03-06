import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../core/constants/colors.dart';

class DateContainer extends StatelessWidget {
  const DateContainer(
      {super.key,
      required this.date,
      required this.isActive,
      required this.onSelect});
  final DateTime date;

  final bool isActive;

  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        height: 20.w,
        width: 20.w,
        decoration: BoxDecoration(
            color: isActive ? kPrimaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(5)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${DateFormat('dd').format(date)}",
              style: TextStyle(
                  color: isActive ? Colors.white : kLightGreyColor,
                  fontSize: 35,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "${DateFormat('MMM').format(date)}",
              style: TextStyle(
                color: isActive ? Colors.white : kLightGreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

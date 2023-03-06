import 'package:flutter/material.dart';

import '../core/constants/colors.dart';

class DayTaskDetailWidget extends StatelessWidget {
  const DayTaskDetailWidget(
      {super.key, required this.title, required this.subtitle});

  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 59,
          width: 322,
          margin: const EdgeInsets.only(top: 11),
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffE7E7E7)),
              borderRadius: BorderRadius.circular(9)),
          child: Center(
              child: Text(
            subtitle,
            style: const TextStyle(
                fontSize: 24,
                color: kPrimaryColor,
                fontWeight: FontWeight.bold),
          )),
        ),
        Positioned(
            left: 137,
            top: 4,
            child: Container(
              color: kWhiteColor,
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xffB7B7B7)),
              ),
            ))
      ],
    );
  }
}

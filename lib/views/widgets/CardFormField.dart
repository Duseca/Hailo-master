import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../core/constants/colors.dart';

class CardFormFieldScreen extends StatefulWidget {
  var card;
   CardFormFieldScreen({Key? key,required this.card}) : super(key: key);

  @override
  State<CardFormFieldScreen> createState() => _CardFormFieldScreenState();
}

class _CardFormFieldScreenState extends State<CardFormFieldScreen> {
  @override
  Widget build(BuildContext context) {
    return CardFormField(
      dangerouslyGetFullCardDetails: false,
      style: CardFormStyle(
          backgroundColor: Colors.white,
          borderRadius: 20,
          borderColor: kLightGreyColor,
          cursorColor: kPrimaryColor,
          placeholderColor: kLightGreyColor,textColor: Colors.black,borderWidth: 1,textErrorColor: Colors.red,

      ),
      autofocus: true,
      onCardChanged: (card) {
        setState(() {
          widget.card = card;
          print(widget.card);
        });


      },
    );
  }
}

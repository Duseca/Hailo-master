
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import '../../../core/common.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/constants.dart';
import 'ListOfPaymentMethods.dart';
// import 'package:stripe_example/utils.dart';
// import 'package:stripe_example/widgets/example_scaffold.dart';
// import 'package:stripe_example/widgets/loading_button.dart';
// import 'package:stripe_example/widgets/response_card.dart';

class PaymentSheetScreen extends StatefulWidget {
  var userId;
  var customerStripeID;
  PaymentSheetScreen({required this.userId,required this.customerStripeID});
  @override
  _PaymentSheetScreenState createState() => _PaymentSheetScreenState();
}

class _PaymentSheetScreenState extends State<PaymentSheetScreen> {
  CardFieldInputDetails? _card;
 CardFormEditController controller=CardFormEditController();
  TokenData? tokenData;

  Future<void> _handleCreateTokenPress() async {
    if (_card == null) {
      return;
    }

    try {
      // 1. Gather customer billing information (ex. email)
      final address = Address(
        city: '',
        country: '',
        line1: '',
        line2: '',
        state: '',
        postalCode: '',
      ); // mocked data for tests

      // 2. Create payment method

      final tokenData = await Stripe.instance.createToken(
          CreateTokenParams.card(
              params: CardTokenParams(address: address, currency: 'USD')));
      // setState(() {
      //   this.tokenData = tokenData;
      // });


      TokenData cardToken = tokenData;

      log("This is the token created: ${cardToken.toJson()}");

      var token=cardToken.id;
      print(token);
      await saveCustomerCardOnStripe(token: token, customerId: widget.customerStripeID);

      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //     content: Text('Success: The token was created successfully!')));
      return;
    } catch (e) {
      // ScaffoldMessenger.of(context) https://still-shore-28834.herokuapp.com/get-customer-cards/cus_NKW4wugsRSPwuN
      //     .showSnackBar(SnackBar(content: Text('Error: $e')));
      rethrow;
    }
  }
  saveCustomerCardOnStripe({required String token, required String customerId}) async {
    try{

      var url = Uri.parse('$api/save-card');
      print(url);
      Map body=
      {
        "token": "${token}",
        "customerId": "${customerId}",
      };
      print(json.encode(body));
      var response = await http.post(url,headers: {"Content-Type": "application/json"},body: json.encode(body));

      var decodedJson=jsonDecode(response.body);
      widget.customerStripeID=decodedJson['customerId'];
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update(
          {'isPaymentAdded':true});
      customToast('Card saved successfully');
      // Get.off(()=>CardListScreen(userId: widget.userId,));
      Get.back();
      print(widget.customerStripeID);
    }
    catch (e){
      print("ERROR OCCURED : ${e.toString()}");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: kPrimaryColor,
          ),
          onPressed: Get.back,
        ),
        title: Text(
          'Payment Settings',
          style: fontBody(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CardFormField(
                      controller: controller,
                      style: CardFormStyle(
                        backgroundColor: Colors.grey.shade200,
                        borderRadius: 20,
                        borderColor: kLightGreyColor,
                        cursorColor: kPrimaryColor,
                        placeholderColor: kLightGreyColor,
                        textColor: Colors.black,
                        borderWidth: 1,
                        textErrorColor: Colors.red,

                      ),
                      autofocus: true,
                      onCardChanged: (card) {

                        setState(() {

                          _card= card;
                          print(_card);
                        });



                      },

              ),
          ),

            SizedBox(height: 20),
            InkWell(
              onTap: () async {
                customToast('Please wait !!!');
                await _handleCreateTokenPress();
              },
              child: Container(
                height: 50,
                width: 194,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9), color: kPrimaryColor),
                child: Center(
                    child: Text(
                      "Add card",
                      style: fontBody(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontColor: kWhiteColor),
                    )),
              ),
            )
            // if (tokenData != null)
            //   ResponseCard(
            //     response: tokenData!.toJson().toPrettyString(),
            //   )
          ],
        ),
      ),
    );
  }

}

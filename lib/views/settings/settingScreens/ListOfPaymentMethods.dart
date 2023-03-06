
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hailo/views/settings/settingScreens/payment.dart';
import 'package:http/http.dart' as http;
import '../../../core/common.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/constants.dart';
import '../../tabs/testtokenscreen.dart';
// import 'package:stripe_example/utils.dart';
// import 'package:stripe_example/widgets/example_scaffold.dart';
// import 'package:stripe_example/widgets/loading_button.dart';
// import 'package:stripe_example/widgets/response_card.dart';

class CardListScreen extends StatefulWidget {
  var userId;
  CardListScreen({required this.userId});
  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  CardFieldInputDetails? _card;
  var userStripeId;
  TokenData? tokenData;
  List eachUserCards=[];
@override
  void initState() {
  // getUserCards(userId: widget.userId);
    // TODO: implement initState
    super.initState();
  }
  createCustomerOnStripe({required String email, required String name}) async {
    try{

      var url = Uri.parse('$api/create-customer');
      print(url);
      Map body=
      {
        "email": "${email}",
        "name": "${name}",
        "description": "Hailo user"
      };

      var response = await http.post(url,headers: {"Content-Type": "application/json"},body: json.encode(body));

      var decodedJson=jsonDecode(response.body);
     var userStripeId=decodedJson['customerId'];

      return userStripeId;
    }
    catch (e){
      print("ERROR OCCURED : ${e.toString()}");
      return 'ERROR';
    }
  }
  getUserCards({required userId}) async {
    eachUserCards=[];
    var user= await FirebaseFirestore.instance.collection('users').doc(userId).get();
     userStripeId=user.get('customer_stripe_id');
     var name=user.get('firstName');
     var email =user.get('email');
     if(userStripeId==''){
        userStripeId =await createCustomerOnStripe(email: email, name: name);
        if(userStripeId!='ERROR'){
          await FirebaseFirestore.instance.collection('users').doc(userId).update(
              {'customer_stripe_id':userStripeId});
        }
     }
    try {
      // var url = Uri.parse(api + '/get-customer-cards/cus_NKCUa6OVHeW366');
      var url = Uri.parse(api + '/get-customer-cards/${userStripeId}');
      var response = await http.get(url);
      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');
      var jsonDecoded=jsonDecode(response.body);
      eachUserCards=jsonDecoded['cards'];

      print('JSON DECODE OF CARDS: ${eachUserCards}');
      return eachUserCards;
      // eachUserCards= jsonDecoded['meditations'];
    }
    catch (e){
      print("Error occured: ${e.toString()}");

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
          'Saved cards',
          style: fontBody(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Container(
              height: Get.height *0.7,
              child: FutureBuilder(
                  future: getUserCards(userId: widget.userId),
                  builder: (context,data){
                    if(data.connectionState==ConnectionState.done) {
                      return ListView.builder(

                          itemCount: eachUserCards.length,
                          itemBuilder: (context, index) {
                            if(eachUserCards.length>0){
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              child: Container(
                                height: Get.height * 0.08,
                                width: Get.width * 0.6,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      eachUserCards[index]['brand'] == 'Visa'
                                          ? Image.asset(
                                        'assets/visa.png',
                                        height: 40,
                                        width: 40,
                                      )
                                          : Image.asset(
                                        'assets/mastercard.png',
                                        height: 40,
                                        width: 40,
                                      ),
                                      Text(
                                        '****  ****  ****  ${eachUserCards[index]['last4']}',
                                        style: TextStyle(
                                            color: Colors.black38,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        ),),
                                    ]),
                              ),
                            );
                          }
                          else{
                            return Text('No saved cards found !!!');
                            }
                          }
                            );
                    }
                    else {
                      return Center(
                        child: CircularProgressIndicator(color: kPrimaryColor,),
                      );
                    }



              }),
            ),
            SizedBox(height: 30,),
            InkWell(
              onTap: (){
                Get.to(()=>PaymentSheetScreen(userId: widget.userId, customerStripeID: userStripeId,));
              },
              child: Container(
                height: 50,
                width: 194,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9), color: kPrimaryColor),
                child: Center(
                    child: Text(
                      'Add card',
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

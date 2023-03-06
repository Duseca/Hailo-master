import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hailo/core/common.dart';
import 'package:hailo/views/root.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../controller/root_controller.dart';
import '../../core/constants/collections.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/functions.dart';

class TaskCreated extends StatefulWidget {
   TaskCreated({
    Key? key, required this.uid,
  }) : super(key: key,);

  final String uid;


  @override
  State<TaskCreated> createState() => _TaskCreatedState();
}

class _TaskCreatedState extends State<TaskCreated> {
  var data = Get.arguments;
  Map<String, dynamic>? paymentIntent;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/checkright.json', width: 150, height: 130),
          const Text(
            "Instant Task\nCreated!",textAlign: TextAlign.center,
            style: TextStyle(fontSize: 35, fontFamily: "Poppins"),
          ),
         SizedBox(height: 10,),

         Container(
           width: MediaQuery.of(context).size.width *0.68,
           height: 50,
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(8),
           ),
           child: Card(
             elevation: 10,
             child: Row(
               children: [
                 Container(
                   width: 90,
                   height: 50,
                   decoration: BoxDecoration(
                     color: Color(0xFF49DDC4),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Image.asset("${data[4]}",color: Colors.white,width: 20,height: 20,
                   ),
                 ),
                 SizedBox(width: 10,),
                 Expanded(
                   child: SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                       child: Text("${data[3]}",style: TextStyle(fontSize: 15,fontFamily: "Poppins",fontWeight: FontWeight.bold),)),
                 )
               ],
             ),
           ),
         ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child:Card(
              elevation: 20,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF7991),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.watch_later_outlined,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 10,),
                        Text(
                          "Instant Task",
                          style: TextStyle(color: Colors.white70, fontFamily: "Poppins", fontSize: 19),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                     Text(DateFormat('dd-MM-yyyy').format(DateTime.now()),style: TextStyle(fontSize: 19,fontFamily: "Poppins",color: Colors.grey),textAlign: TextAlign.center,),
                      Text("${data[1]}",style: TextStyle(fontSize: 19,fontFamily: "Poppins",color: Colors.grey),), //Address
                    ],
                  ),
                  Divider(),
                  if(data[3] == 'Drive')
                    Text("${data[6]}",style: TextStyle(fontSize: 19,fontFamily: "Poppins",color: Colors.grey,letterSpacing: 1),)
                  else
                    Text("${data[5]}",style: TextStyle(fontSize: 19,fontFamily: "Poppins",color: Colors.grey,letterSpacing: 1),),

                   Divider(),
                  Text("\$" "${data[0]}",style: TextStyle(fontSize: 39,fontFamily: "Poppins",color: Colors.green),),


                ],
              ),
            ),
          ),

          //cancel button
          Padding(
            padding: const EdgeInsets.only(left: 18.0,right: 18.0,top: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade400,
                padding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
              ),
              onPressed: () async{


                await FirebaseFirestore.instance.collection("instantTask").doc(widget.uid).delete().then((value) =>Get.offAll(Root()));

              },
              child: Center(
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
                  ))
              ,),
          ),

          //Done Button
          Padding(
            padding: const EdgeInsets.only(left: 18.0,right: 18.0,top: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
              ),
              onPressed: () async{



                // customToast("Instant Task Created.")
                var doc = await usersCollection.doc(widget.uid).get();
                await sendNotificationCareTaker
                    .call({"title": "Posted an instant job", "description": "${doc["firstName"]} posted a job for ${data[3]}",});
                 Get.offAllNamed("/root",parameters: {"uid":widget.uid});

              },
              child:const Center(
                  child: Text(
                    "Done",
                    style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
                  ))
              ,),
          )
        ],
      ),
    );
  }


}


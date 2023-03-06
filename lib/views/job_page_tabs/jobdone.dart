import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hailo/core/utils/common.dart';

import '../../core/constants/collections.dart';
import '../../core/constants/colors.dart';
import '../root.dart';



class JobDone extends StatefulWidget {
   JobDone({Key? key}) : super(key: key);

  @override
  State<JobDone> createState() => _JobDoneState();
}

class _JobDoneState extends State<JobDone> {
  String? tid = Get.parameters["tid"];

  String? cid = Get.parameters["cid"];

  double rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Center(
          child:StreamBuilder<DocumentSnapshot>(
            stream: longtermCollection.doc(tid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return customProgressIndicator();
              DocumentSnapshot data = snapshot.data!;
              List<dynamic> service = data['caregiverService'];
              return Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 30,
                        width: 70,
                      ),
                      Positioned(
                        height: 30,
                        width: 30,
                        left: 44,
                        child: service.length >= 3
                            ? Container(
                            decoration: BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
                            child: Center(
                              child: Image.asset(
                                "${service[2]['icon']}",
                                height: 18,
                                width: 18,
                                color: kWhiteColor,
                              ),
                            ))
                            : Container(
                          height: 15,
                          width: 15,
                          decoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
                        ),
                      ),
                      Positioned(
                        height: 30,
                        width: 30,
                        left: 23,
                        child: service.length >= 2
                            ? Container(
                          decoration: BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
                          child: Center(
                            child: Image.asset(
                              "${service[1]['icon']}",
                              height: 15,
                              width: 15,
                              color: kWhiteColor,
                            ),
                          ),
                        )
                            : Container(
                          height: 15,
                          width: 15,
                          decoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
                        ),
                      ),
                      Positioned(
                          height: 30,
                          width: 30,
                          left: 2,
                          child: Container(
                            decoration: BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
                            child: Center(
                              child: Image.asset(
                                "${service[0]['icon']}",
                                height: 15,
                                width: 16,
                              ),
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  service.length == 1 ? Text(
                    '${service[0]['name']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ) : Text(
                    '${service[0]['name']} and +${service.length - 1}',textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: kPrimaryColor,
            ),
            onPressed: Get.back,
          ),
        ),
      ),


      body: StreamBuilder<DocumentSnapshot>(
        stream: careTakersCollection.doc(cid).snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return customProgressIndicator();
      DocumentSnapshot data = snapshot.data!;
      return Center(
        child: Column(
          children: [
            SizedBox(height: 40,),
            Container(
              height: 55,
              width: 55,
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  color: Colors.red.shade300,
                  shape: BoxShape.circle
              ),
              child: Icon(Icons.check, color: Colors.white,),
            ),
            SizedBox(height: 30,),
            Text(
              'Job is Done !',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins'
              ),
            ),
            SizedBox(height: 30,),
            Card(
                elevation: 2,
                /*  shadowColor: Colors.black,*/
                child: SizedBox(
                  width: 300,
                  height: 110,
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 58,
                            width: 58,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: data["profilePicture"].isEmpty
                                  ? Image.asset(
                                "assets/placeholderProfile.png",
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                              )
                                  : CachedNetworkImage(
                                imageUrl: data["profilePicture"],
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['firstName'] + " " + data['lastName'],
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'PoppinsRegular'),
                              ),
                              SizedBox(height: 10,),
                              Text(
                                data['dob'],

                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: kLightGreyColor, fontFamily: 'Poppins'),
                              ),
                            ],
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(
                                Icons.star,
                                color: Color(0xffFFD704),
                                size: 14,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                '4.9',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xffFFD704)),
                              ),
                            ],
                          ),

                        ]),
                  ),
                )

            ),
            SizedBox(height: 40,),
            Text("Rate the Cargiver", style: TextStyle(letterSpacing: 1, fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),),
            SizedBox(height: 10,),
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.69,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.09,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.4)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                  updateOnDrag: true,
                  onRatingUpdate: (rating) {
                    setState(() {
                      this.rating = rating;
                      print(this.rating);
                    });

                  },
                ),
              ),
            ),
            SizedBox(height: 80,),
            InkWell(
              onTap: () async{
                await careTakersCollection.doc(cid).set({'rating': this.rating}, SetOptions(merge: true));
                print(this.rating);

                //Get.to(() => Root());
                },
              child: Container(
                height: 52,
                width: 332,
                decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: kPrimaryColor)),
                child: const Center(
                  child: Text(
                    'Done',
                    style: TextStyle(
                        fontSize: 20,
                        color: kWhiteColor,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
      )
    );
  }
}

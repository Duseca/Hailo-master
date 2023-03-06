import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hailo/core/constants/collections.dart';
import 'package:hailo/core/utils/common.dart';

import '../../../../../core/common.dart';
import '../../../../../core/constants/colors.dart';
import 'createprofile.dart';

class EditProfiles extends StatelessWidget {
  EditProfiles({Key? key}) : super(key: key);

  String? uid = Get.parameters["uid"];


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
            'Edit Profiles',
            style: fontBody(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 22.0, right: 22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<QuerySnapshot>(
                      stream: usersCollection.doc(uid).collection("userType").snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return customProgressIndicator();

                        List<DocumentSnapshot> udata =snapshot.data!.docs;

                         return ListView.builder(
                             scrollDirection: Axis.vertical,
                             shrinkWrap: true,
                            itemCount: udata.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: kSecondaryColor,
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: ListTile(
                                    leading: Icon(Icons.person_pin,color: kWhiteColor,),
                                    title: Text("${udata[index]['relationType']}",style: fontBody(fontSize: 20,fontColor: kWhiteColor),),
                                    trailing: IconButton(onPressed: () async{

                                      await usersCollection.doc(uid).collection("userType").doc(udata[index].id).delete();


                                    }, icon: Icon(Icons.delete,color: kWhiteColor,),
                                      
                                    ),
                                  ),
                                ),
                              );
                            }
                        );
                      }
                  ),

                  SizedBox(height: 28,),
                  GestureDetector(
                    onTap: () => Get.to(() => CreateProfile()),
                    child: Container(
                      height: 52,
                      width: 332,
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: kPrimaryColor)),
                      child: const Center(
                        child: Text(
                          'Create new profile',
                          style: TextStyle(
                              fontSize: 20,
                              color: kWhiteColor,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ]
            )
        )
    );
  }
}



        /*StreamBuilder<QuerySnapshot>(
          stream: usersCollection.doc(uid).collection("userType").snapshots(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return customProgressIndicator();
            }
            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
                itemBuilder: (context,index){
                return ListTile(
                  leading: Icon(Icons.ac_unit_outlined),
                  title: Text(snapshot.data?.docs[index].data("relationType")).zz,
                );
                }

            )
          },
        );*/





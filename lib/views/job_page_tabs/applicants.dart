import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hailo/core/common.dart';
import 'package:hailo/core/constants/collections.dart';

import 'package:hailo/core/constants/colors.dart';
import 'package:hailo/core/constants/images.dart';
import 'package:hailo/views/job_page_tabs/application.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../core/utils/common.dart';

class Applicants extends StatefulWidget {
  final String uid, tid;
  Applicants({super.key, required this.uid, required this.tid});

  @override
  State<Applicants> createState() => _ApplicantsState();
}

class _ApplicantsState extends State<Applicants> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaginateFirestore(
        onEmpty: Padding(
          padding: const EdgeInsets.symmetric(vertical: 208.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                  backgroundColor: kPrimaryColor.withOpacity(0.1),
                  radius: 70,
                  child: Image.asset("assets/noapplicants.png",)),
              SizedBox(height: 10,),
              Text(
                'No Applicants Yet',style: fontBody(fontSize: 16),
              ),
            ],
          ),
        ),

        padding: const EdgeInsets.symmetric(horizontal: 19),
        itemBuilder: (context, documentSnapshots, index) {
          DocumentSnapshot application = documentSnapshots[index];


          return StreamBuilder<DocumentSnapshot>(
              stream: careTakersCollection.doc(application.id).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return customProgressIndicator();
                DocumentSnapshot udata = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
                    onTap: () {
                      Get.to(() => Application(uid: widget.uid, tid: widget.tid, cid: application.id));
                    },
                    tileColor: kWhiteColor,
                    leading: udata["profilePicture"].isEmpty
                        ? Image.asset(
                            "assets/placeholderProfile.png",
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              imageUrl: udata["profilePicture"],
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                          ),
                    title: Text(udata['firstName'] + " " + udata['lastName'], style: fontBody(fontSize: 16, fontWeight: FontWeight.w400)),
                    subtitle: Text(calculateAge(udata['dob']), style: fontBody(fontSize: 14)),
                    trailing: Container(
                      height: 33,
                      width: 33,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kSecondaryColor)),
                      child: Center(
                          child: GestureDetector(
                            onTap: () async{
                                await longtermCollection.doc(widget.tid).collection('applicants').doc(application.id).delete();
                            },
                            child: Container(
                              child: Image.asset(
                        Hdelete,
                        height: 12,
                        width: 11,
                      ),
                            ),
                          )),
                    ),
                  ),
                );
              });
        },
        itemBuilderType: PaginateBuilderType.listView,
        query: longtermCollection.doc(widget.tid).collection('applicants').orderBy('appliedAt',descending: true)
      ),
    );
  }
}

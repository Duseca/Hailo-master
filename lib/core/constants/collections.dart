import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference usersCollection = FirebaseFirestore.instance.collection("users");
CollectionReference chatsCollection = FirebaseFirestore.instance.collection("chats");
CollectionReference careTakersCollection = FirebaseFirestore.instance.collection("careTakers");
CollectionReference instantTaskCollection = FirebaseFirestore.instance.collection("instantTask");
CollectionReference healthConditionsCollection = FirebaseFirestore.instance.collection("healthConditions");
CollectionReference categoriesCollection = FirebaseFirestore.instance.collection("categories");
CollectionReference longtermCollection = FirebaseFirestore.instance.collection("longTerm");
CollectionReference jobsCollection = FirebaseFirestore.instance.collection("jobs");
CollectionReference jobsInstantCollection = FirebaseFirestore.instance.collection("jobsInstant");
CollectionReference chatSupportCollection = FirebaseFirestore.instance.collection("userSupport");


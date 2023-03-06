import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:hailo/core/constants/colors.dart';
import 'package:hailo/core/utils/progress_dialog_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pinput.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';

import '../core/common.dart';
import '../core/constants/collections.dart';
import '../core/constants/constants.dart';

class SignupController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController(),
        firstNameController = TextEditingController(),
      lastNameController = TextEditingController(),
      dobController = TextEditingController(),
      genderController = TextEditingController(),
      passwordController = TextEditingController(), rePasswordController = TextEditingController(),
      countryController = TextEditingController(text: "United States");
  var customerStripeId;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs, phoneCodeController = TextEditingController(text: "+1").obs;
  final ImagePicker imagePicker = ImagePicker();
  final PageController pageController = PageController();
  final countryPicker = const FlCountryCodePicker();
  var imageName = "".obs, imageSize = 0.obs, imagePath = "".obs, termsAccepted = false.obs;
  bool canVerifyOTP = false;
  bool isPaymentAdded = false;
  String verificationID = "", receivedOTP = "";
  RxInt currentPage = 0.obs;
  DateTime _selectedDate = DateTime.now();
  CardFieldInputDetails? card;
  var eachUserCards=[];
  List<String> pageHeading = [
    "Signup",
    "Phone Number",
    "Phone Verification",
    "Profile Photo",
    "Payment Details",
    "Terms and Conditions",
  ];

  List<String> nextButton = [
    "Next",
    "Next",
    "Verify",
    "Next",
    "Next",
    "Done",
  ];

  final defaultPinTheme = PinTheme(
    width: 50,
    height: 65,
    textStyle: fontBody(fontSize: 30),
    decoration: BoxDecoration(
      color: const Color(0xffEDEDED),
      border: Border.all(color: kWhiteColor),
      borderRadius: BorderRadius.circular(15),
    ),
  );

  late PinTheme focusedPinTheme;

  late PinTheme submittedPinTheme;

  @override
  void onInit() {
    focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: kPrimaryColor),
    );
    submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: kPrimaryColor.withOpacity(0.6)),
    );
    super.onInit();
  }

  onNext() async {
    switch (currentPage.value) {
      case 0:
        //signup
        if (!formKey.currentState!.validate()) {
          return;
        }
        currentPage.value++;
        pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        break;
      case 1:
        //phone number
        if (phoneNumberController.value.text.isEmpty) {
          customToast("Please enter your phone number");
          return;
        }
        customToast("please wait...");
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '${phoneCodeController.value.text} ${phoneNumberController.value.text}',
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {
            customToast(e.code);
          },
          timeout: const Duration(seconds: 60),
          codeSent: (String verificationId, int? resendToken) {
            customToast("OTP sent");
            verificationID = verificationId;
            currentPage.value++;
            pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
        break;
      case 2:
      //otp
        if (!canVerifyOTP) {
          customToast("Please enter the OTP");
          return;
        }
        try {
          PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationID, smsCode: receivedOTP);
          await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
            await createCustomerOnStripe(email: emailController.text, name: firstNameController.text);
            pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
            currentPage.value++;
          });
        } on FirebaseAuthException catch (e) {
          customToast(e.code);
        }
        break;
      case 3:
        //profile photo

        currentPage.value++;

        pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);

        break;
      case 4:
        //Payment Details
      if(card==null){
        customToast('Please fill out card details or skip for now');
        isPaymentAdded=false;
      }
      else {
        print(card);
        _handleCreateTokenPress();
        isPaymentAdded=true;
        currentPage.value++;
        createCustomerOnStripe(
            email: emailController.text, name: firstNameController.text);
        pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      }
        break;
      case 5:
        //terms
        if (!termsAccepted.value) {
          customToast("Please accept our Terms of Condition");
          return;
        }
        ProgressDialogUtils.showProgressDialog();
        try {
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text)
              .then((value) async {
            String profilePicture = "";
            String uid = value.user!.uid;

            if (imagePath.value.isNotEmpty) {
              String ext = imagePath.value.split(".").last;
              final storageRef = FirebaseStorage.instance.ref();
              final usersAvatarRef = storageRef.child("users/$uid/${DateTime.now().millisecondsSinceEpoch}.$ext");

              try {
                await usersAvatarRef.putFile(File(imagePath.value));
                profilePicture = await usersAvatarRef.getDownloadURL();
              } on FirebaseException catch (e) {
                customToast(e.toString());
              }
            }

            await usersCollection.doc(uid).set({
              "activeNow": false,
              "firstName": firstNameController.text.trim(),
              "lastName": lastNameController.text.trim(),
              "dob": dobController.text,
              "gender": genderController.text,
              "email": emailController.text.toLowerCase().trim(),
              "phoneNumber": "${phoneCodeController.value.text} ${phoneNumberController.value.text}",
              "profilePicture": profilePicture,
              "termsAccepted": termsAccepted.value,
              "joined": DateTime.now(),
              "messageToken": "",
              "isPaymentAdded":isPaymentAdded,
              "customer_stripe_id": customerStripeId,

            }).then((value) {
              customToast("Account created successfully");
              Get.offAllNamed("/root", parameters: {"uid": uid});
            });
          });
        } on FirebaseAuthException catch (e) {
          switch (e.code) {
            case "email-already-in-use":
              customToast("Email already in use");
              break;
            case "weak-password":
              customToast("Weak password");
              break;
            case "invalid-email":
              customToast("Invalid email format");
              break;
          }
        }
        break;
    }
  }

  Future<void> _handleCreateTokenPress() async {
    if (card == null) {
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
      saveCustomerCardOnStripe(token: token, customerId: customerStripeId);
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
      customerStripeId=decodedJson['customerId'];
      print(customerStripeId);
    }
    catch (e){
      print("ERROR OCCURED : ${e.toString()}");
    }
  }

  getUserCards({required userStripeId}) async {
    eachUserCards=[];

    try {
      var url = Uri.parse(api + '/get-customer-cards/$userStripeId');
      var response = await http.get(url);
      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');
      var jsonDecoded=jsonDecode(response.body);
      // eachUserCards= jsonDecoded['meditations'];
    }
    catch (e){
      print("Error occured: ${e.toString()}");

    }
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
    print(json.encode(body));
    var response = await http.post(url,headers: {"Content-Type": "application/json"},body: json.encode(body));

      var decodedJson=jsonDecode(response.body);
     customerStripeId=decodedJson['customerId'];
     print(customerStripeId);
  }
  catch (e){
    print("ERROR OCCURED : ${e.toString()}");
  }
}
  void setOTP(String otp) async{
    canVerifyOTP = true;
    receivedOTP = otp;

    }
  void selectGender() => Get.defaultDialog(
        title: "Select Gender",
        titleStyle: fontBody(fontSize: 20, fontWeight: FontWeight.w500, fontColor: kPrimaryColor),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                genderController.text = "Male";
                Get.back();
              },
              title: Text("Male", style: fontBody(fontSize: 15)),
            ),
            ListTile(
              onTap: () {
                genderController.text = "Female";
                Get.back();
              },
              title: Text("Female", style: fontBody(fontSize: 15)),
            ),
          ],
        ),
        backgroundColor: kWhiteColor,
      );

  void selectDate() => Get.bottomSheet(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 270,
            child: ScrollDatePicker(
              minimumDate: DateTime(1950),
              maximumDate: DateTime(2100),
              selectedDate: _selectedDate,
              locale: const Locale('en'),
              onDateTimeChanged: (DateTime value) {
                _selectedDate = value;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () {
                dobController.text = DateFormat("dd-MM-yyyy").format(_selectedDate);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                primary: kPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Set date", style: fontBody(fontSize: 18, fontColor: kWhiteColor, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      backgroundColor: kWhiteColor);

  void pickImage({bool gallery = false}) async {
    final XFile? image = await imagePicker.pickImage(source: gallery ? ImageSource.gallery : ImageSource.camera);
    if (image == null) return;
    imageSize.value = await image.length() ~/ 1000;
    if (imageSize.value > 700) {
      customToast("Max file limit exceeds");
      return;
    }

    imageName.value = image.name;
    imagePath.value = image.path;
  }

  void openImageSelect() => Get.defaultDialog(
      title: "Select Profile Picture",
      titleStyle: fontBody(fontSize: 20, fontWeight: FontWeight.w500, fontColor: kPrimaryColor),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: () {
              pickImage(gallery: true);
              Get.back();
            },
            title: Text("Open Gallery", style: fontBody(fontSize: 15)),
          ),
          ListTile(
            onTap: () {
              pickImage();
              Get.back();
            },
            title: Text("Open Camera", style: fontBody(fontSize: 15)),
          ),
        ],
      ),
      backgroundColor: kWhiteColor);

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    genderController.dispose();
    firstNameController.dispose();
    phoneNumberController.value.dispose();
    phoneCodeController.value.dispose();
    countryController.dispose();
    pageController.dispose();
    rePasswordController.dispose();
    super.onClose();
  }
}

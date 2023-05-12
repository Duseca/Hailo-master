import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:hailo/core/constants/colors.dart';
import 'package:hailo/core/utils/form_validators.dart';
import 'package:hailo/views/widgets/CardFormField.dart';
import 'package:pinput/pinput.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/signup_controller.dart';
import '../core/common.dart';

class Signup extends GetView<SignupController> {
  const Signup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: context.mediaQueryViewInsets.bottom == 0
          ? null
          : FloatingActionButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
              backgroundColor: kWhiteColor,
              child: const Icon(
                Icons.keyboard_hide_rounded,
                color: kPrimaryColor,
              ),
            ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          color: kPrimaryColor,
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Obx(() => Text(controller.pageHeading[controller.currentPage.value])),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller.pageController,
        children: [
          //signup
          Form(
            key: controller.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(32),
              children: [
                const SizedBox(height: 20),
                //F name
                TextFormField(
                  controller: controller.firstNameController,
                  keyboardType: TextInputType.name,
                  style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    labelText: "First Name",
                    labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                    focusedBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                  ),
                  validator: nameValidator,
                ),
                const SizedBox(height: 20),
                //L name
                TextFormField(
                  controller: controller.lastNameController,
                  keyboardType: TextInputType.name,
                  style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    labelText: "Last Name",
                    labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                    focusedBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                  ),
                  validator: nameValidator,
                ),
                const SizedBox(height: 20),
                //DOB
                TextFormField(
                  controller: controller.dobController,
                  keyboardType: TextInputType.text,
                  readOnly: true,
                  onTap: () => controller.selectDate(),
                  style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    labelText: "Date of Birth",
                    labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                    suffixIcon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/calender_icon.png", width: 20),
                      ],
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                    focusedBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                  ),
                  validator: dobValidator,
                ),
                const SizedBox(height: 20),
                //Gender
                TextFormField(
                  controller: controller.genderController,
                  readOnly: true,
                  onTap: () => controller.selectGender(),
                  keyboardType: TextInputType.text,
                  style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    labelText: "Gender",
                    labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                    suffixIcon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/dropdown_icon.png", width: 20),
                      ],
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                    focusedBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                  ),
                  validator: genderValidator,
                ),
                const SizedBox(height: 20),
                //Email
                TextFormField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                    focusedBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                  ),
                  validator: emailValidator,
                ),
                const SizedBox(height: 20),
                //Password
                TextFormField(
                  controller: controller.passwordController,
                  obscureText: true,
                  style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                    focusedBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                  ),
                  validator: passwordValidator,
                ),
                const SizedBox(height: 20),
                //Password
                TextFormField(
                  controller: controller.rePasswordController,
                  obscureText: true,
                  style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: "Re-type Password",
                    labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                    focusedBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please re enter your password";
                    }
                    if (value != controller.passwordController.text) {
                      return "Password does not match";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          //phone number
          ListView(
            padding: const EdgeInsets.all(32),
            children: [
              Image.asset("assets/signup_image.png", fit: BoxFit.fitWidth),
              const SizedBox(height: 20),
              //Phone
              TextFormField(
                controller: controller.phoneNumberController.value,
                keyboardType: TextInputType.number,
                style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                  prefixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            final code = await controller.countryPicker.showPicker(context: context);
                            if (code != null) {
                              controller.countryController.text = code.name;
                              controller.phoneCodeController.value.text = code.dialCode;
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            primary: kPrimaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(controller.phoneCodeController.value.text, style: fontBody(fontSize: 15, fontColor: Color(0xffF5F5F5))),
                        ),
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                ),
              ),
            ],
          ),
          //otp
          ListView(
            padding: const EdgeInsets.all(32),
            children: [
              Obx(
                () => Text(
                  "Enter the six digit code that\nsent to ${controller.phoneCodeController.value.text} ${controller.phoneNumberController.value.text}",
                  textAlign: TextAlign.center,
                  style: fontBody(fontSize: 14, fontWeight: FontWeight.w400, fontColor: const Color(0xff898A8D)),
                ),
              ),
              const SizedBox(height: 100),
              Pinput(
                length: 6,
                defaultPinTheme: controller.defaultPinTheme,
                focusedPinTheme: controller.focusedPinTheme,
                submittedPinTheme: controller.submittedPinTheme,
                validator: (s) {},
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                onCompleted: (otp) => controller.setOTP(otp),


              ),
            ],
          ),
          //profile picture
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const SizedBox(height: 70),
                Obx(
                  () => ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: controller.imagePath.value.isEmpty
                        ? Image.asset("assets/placeholderProfile.png", width: context.width / 2, height: context.width / 2, fit: BoxFit.cover)
                        : Image.file(File(controller.imagePath.value), width: context.width / 2, height: context.width / 2, fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 70.0, bottom: 15.0),
                  child: ListTile(
                    onTap: () => controller.openImageSelect(),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Color(0xffE7E7E7))),
                    title: Obx(
                      () => RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: controller.imageName.value.isEmpty ? "No file" : controller.imageName.value,
                                style: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xff333333))),
                            TextSpan(
                                text: controller.imageName.value.isEmpty ? " (0KB)" : " (${controller.imageSize.value}KB)",
                                style: fontBody(fontSize: 12, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7))),
                          ],
                        ),
                      ),
                    ),
                    trailing: Image.asset("assets/cloudupload_icon.png", width: 20),
                  ),
                ),
                Text("Maximum 700KB",
                    textAlign: TextAlign.center, style: fontBody(fontSize: 14, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)))
              ],
            ),
          ),

          //--------PAYMENT DETAILS---------------
          Form(
            key: controller.formKey2,
            child: ListView(
              padding: const EdgeInsets.all(32),
              children: [
                Text('Enter card details',style: TextStyle(
                  color: Colors.black,fontSize: 24
                ),),
                SizedBox(height: 15,),
              StatefulBuilder(
                builder: (context,state) {
                  return CardFormField(
                    style: CardFormStyle(
                      backgroundColor: Colors.white,
                      borderRadius: 20,
                      borderColor: kLightGreyColor,
                      cursorColor: kPrimaryColor,
                      placeholderColor: kLightGreyColor,textColor: Colors.black,borderWidth: 1,textErrorColor: Colors.red,

                    ),
                    autofocus: true,
                    onCardChanged: (card) {
                      state(() {
                        controller.card = card;
                         print(controller.card);
                      });


                    },
                  );
                }
              ),
                // const SizedBox(height: 20),
                // //card number
                // TextFormField(
                //   controller: null,
                //   keyboardType: TextInputType.number,
                //   style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                //   decoration: InputDecoration(
                //     labelText: "Card Number",
                //     labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                //     suffixIcon: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [Image.asset("assets/mastercard.png", width: 30)],
                //     ),
                //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                //     enabledBorder:
                //         OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                //     focusedBorder:
                //         OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                //   ),
                // ),
                // const SizedBox(height: 20),
                // //exp
                // TextFormField(
                //   controller: null,
                //   keyboardType: TextInputType.name,
                //   style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                //   decoration: InputDecoration(
                //     labelText: "Exp. Date",
                //     labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                //     enabledBorder:
                //         OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                //     focusedBorder:
                //         OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                //   ),
                // ),
                // const SizedBox(height: 20),
                // //cvv
                // TextFormField(
                //   controller: null,
                //   keyboardType: TextInputType.number,
                //   style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                //   decoration: InputDecoration(
                //     labelText: "CVV Number",
                //     labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                //     enabledBorder:
                //         OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                //     focusedBorder:
                //         OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                //   ),
                // ),
                // const SizedBox(height: 20),
                // //name
                // TextFormField(
                //   controller: null,
                //   keyboardType: TextInputType.name,
                //   style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                //   decoration: InputDecoration(
                //     labelText: "Name on Card",
                //     labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                //     enabledBorder:
                //         OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                //     focusedBorder:
                //         OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                //   ),
                // ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          //-----------TERMS AND CONDITIONS--------------
          Padding(
            padding: const EdgeInsets.all(32),
            child: ListView(
              children: [
                Container(
                  height: context.height / 2,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Color(0xffE5E5E5), width: 2)),
                  child: ListView(
                    padding: const EdgeInsets.all(15),
                    controller: ScrollController(),
                    children: const [
                      Text("LEGAL DOCUMENT", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(
                          "Malesuada tincidunt ante condimentum eget pulvinar id vulputate sit ut. Nibh quis etiam nibh nullam diam auctor. Eu a tellus molestie urna nulla odio nunc. Facilisi vitae molestie quam semper bibendum. Aliquet mi dictum purus feugiat lorem bibendum diam pharetra. Faucibus amet, mi senectus purus. Tellus viverra non adipiscing velit arcu, massa commodo commodo, eget. Amet, ut mauris non pellentesque tellus dolor vivamusNunc eu neque ultrices tristique. A viverra amet interdum lacus, amet sed. Auctor pellentesque pharetra ullamcorper ornare auctor varius egestas rhoncus, lobortis. Tristique egestas et aliquam libero ultrices auctor. Quis fusce proin neque felis felis magna. In tempus massa ullamcorper viverra. Tincidunt senectus luctus lectus blandit tortor. Ipsum sollicitudin arcu sit amet rutrum semper turpis amet, ut. Blandit habitasse sit pulvinar donec sit in massa convallis quis. Rhoncus massa nisl commodo pulvinar placerat tincidunt posuere ac.Lectus malesuada mattis tristique arcu, in consequat cursus id. Adipiscing consectetur lectus auctor amet odio suspendisse varius sit tellus. Lectus a mauris nulla dui scelerisque.Quis fusce proin neque felis felis magna. In tempus massa ullamcorper viverra. Tincidunt senectus luctus lectus blandit tortor. Ipsum sollicitudin arcu sit amet rutrum semper turpis amet, ut. Blandit habitasse sit pulvinar donec sit in massa convallis quis. Rhoncus massa nisl commodo pulvinar placerat tincidunt posuere ac.")
                    ],
                  ),
                ),
                Container(
                  height: context.height / 2,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Color(0xffE5E5E5), width: 2)),
                  child: ListView(
                    padding: const EdgeInsets.all(15),
                    controller: ScrollController(),
                    children: const [
                      Text("Terms and Conditions", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Hailo provides a personalized multipurpose digital marketplace platform (“Hailo Platform”)that enables you (“Client”) to conveniently find, request, and receive certain home careservices from third-party providers that meet your needs and requirements. These third-partyproviders are licensed/certified Home Care Aides or their jurisdictional equivalents(“Caregivers”) who operate as independent contractors on the Hailo Platform. These Terms ofUse (“Terms”) govern your access or use, from within the United States and its territories andpossessions, of the Hailo Platform and any related content or services (collectively, the“Services,” as more fully defined below in Section 3) made available in the United States andits territories and possessions by HailoCare, Inc. and its subsidiaries, representatives, affiliates,officers, and directors (collectively, “Hailo” or “HailoCare”). PLEASE READ THESE TERMSCAREFULLY, AS THEY CONSTITUTE A LEGAL AGREEMENT BETWEEN YOU ANDHAILOCARE. In these Terms, the words “including” and “include” mean “including, but notlimited to.”')
                    ],
                  ),
                ),
                Obx(
                  () => CheckboxListTile(
                    value: controller.termsAccepted.value,
                    onChanged: (val) {
                      controller.termsAccepted.value = val!;
                    },
                    activeColor: kPrimaryColor,
                    title: RichText(
                      text: TextSpan(style: fontBody(fontSize: 14), children: [
                        const TextSpan(text: "I have read ", style: TextStyle(color: Color(0xffD8D8D8))),
                        TextSpan(
                          text: "Legal Document",
                          recognizer: TapGestureRecognizer()..onTap = () => {},
                          style: const TextStyle(color: Color(0xff49DDC4), decoration: TextDecoration.underline),
                        ),
                        const TextSpan(text: " and accept ", style: TextStyle(color: Color(0xffD8D8D8))),
                        TextSpan(
                          text: "Terms of Condition",
                          recognizer: TapGestureRecognizer()..onTap = () async {
                            final Uri _url = Uri.parse('https://hailocare.com/tos/?amp=1');
                            await launchUrl(_url);
                          },
                          style: const TextStyle(color: Color(0xff49DDC4), decoration: TextDecoration.underline),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: controller.currentPage.value == 3 || controller.currentPage.value == 4
                          ? ElevatedButton.icon(
                              onPressed: () {
                                controller.currentPage.value++;
                                controller.pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: kWhiteColor,
                                padding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: Text("Skip", style: fontBody(fontSize: 18, fontWeight: FontWeight.w500)),
                              label: const Icon(Icons.arrow_forward, color: kBlackColor),
                            )
                          : SizedBox.shrink(),
                    ),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        onPressed: () => controller.onNext(),
                        style: ElevatedButton.styleFrom(
                          primary: kPrimaryColor,
                          padding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: Text(controller.nextButton[controller.currentPage.value],
                            style: fontBody(fontSize: 18, fontColor: kWhiteColor, fontWeight: FontWeight.w500)),
                        label: const Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSmoothIndicator(
                activeIndex: controller.currentPage.value,
                count: 6,
                effect: const ExpandingDotsEffect(
                  expansionFactor: 5,
                  dotWidth: 5.0,
                  dotHeight: 5.0,
                  dotColor: Color(0xffE0E0E0),
                  activeDotColor: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

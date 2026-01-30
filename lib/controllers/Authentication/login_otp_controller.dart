// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/apiHelper.dart';
import 'signup_controller.dart';

class LoginOtpController extends GetxController {
  SignupController signupController = Get.find<SignupController>();
  String screen = 'login_otp_controller.dart';
  double second = 0;
  var maxSecond;
  Timer? time;
  Timer? time2;
  final TextEditingController cMobileNumber = TextEditingController();
  dynamic smsCode = '';
  APIHelper apiHelper = APIHelper();

  String? phonenois;
  String? countrycodeis;

  String countryCode = "+91";

  updateCountryCode(String? value) {
    countryCode = value ?? "+91";
    log('country code is $countryCode');
    update();
  }

  init() {}

  timer() {
    maxSecond = 60;
    time = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (maxSecond > 0) {
        maxSecond--;
        update();
      } else {
        time!.cancel();
        update();
      }
    });
  }

//check otp
  // void checkOtp(String mobile, String verificationId, String smsCode) async {
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   global.showOnlyLoaderDialog();
  //   try {
  //     var credential = PhoneAuthProvider.credential(
  //         verificationId: verificationId, smsCode: smsCode);
  //     await auth.signInWithCredential(credential).then((result) async {
  //       global.hideLoader();

  //       log('Success loginOtpcontroller-> ${result.user}');
  //       await loginController.loginAstrologer(mobile);
  //     });
  //   } on Exception catch (e) {
  //     global.hideLoader();

  //     String errorMessage = 'An error occurred, please try again later.';
  //     if (e is FirebaseAuthException) {
  //       String errorCode = e.code;
  //       switch (errorCode) {
  //         case 'invalid-verification-code':
  //           errorMessage = 'Invalid Pin';
  //           break;
  //         case 'invalid-verification-id':
  //           errorMessage = 'The verification ID is invalid.';
  //           break;
  //         case 'invalid-phone-number':
  //           errorMessage = 'The phone number is invalid.';
  //           break;
  //         case 'too-many-requests':
  //           errorMessage = 'Too many requests, please try again later.';
  //           break;
  //         default:
  //           // Handle other Firebase authentication errors
  //           errorMessage =
  //               'An unexpected error occurred, please try again later.';
  //       }
  //       global.showToast(
  //         message: errorMessage,
  //       );
  //       debugPrint("check otp Exception - $screen - sendOTP():$errorMessage");
  //     }
  //   }
  // }

  bool countryvalidator=false;

  bool validedPhone() {

    return countryvalidator;
  }

}

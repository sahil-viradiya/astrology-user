// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/device_detail_model.dart';
import '../../services/apiHelper.dart';
import '../../views/Authentication/OtpScreens/login_otp_screen.dart';
import '../../views/Authentication/login_screen.dart';
import '../../views/HomeScreen/home_screen.dart';
import '../HomeController/call_controller.dart';
import '../HomeController/chat_controller.dart';
import '../HomeController/live_astrologer_controller.dart';
import '../HomeController/report_controller.dart';
import '../following_controller.dart';
import 'login_otp_controller.dart';

class LoginController extends GetxController {
  String screen = 'login_controller.dart';
  APIHelper apiHelper = APIHelper();
  //Login
  final pinEditingController = TextEditingController(text: '');

  ChatController chatController = Get.find<ChatController>();
  CallController callController = Get.find<CallController>();
  ReportController reportController = Get.find<ReportController>();
  FollowingController followingController = Get.find<FollowingController>();
  final liveAstrologerController = Get.find<LiveAstrologerController>();
  final loginOtpController = Get.put(LoginOtpController());

  String signupText = tr('By signin up you agree to our');
  String termsConditionText = tr('Terms of Services');
  String andText = tr('and');
  String privacyPolicyText = tr('Privacy Policy');
  String notaAccountText = tr("Don't have an account?");
  var loaderVisibility = true;
  final urlTextContoller = TextEditingController();
  Map<String, dynamic>? dataResponse;

  String phoneOrEmail = '';
  String otp = '';
  bool isInitIos = false;
  final apihelper = APIHelper();

  String? phonenois;
  String? countrycodeis;
  int loginTypeis = 0;
  @override
  void onInit() async {
    await init();
    super.onInit();
  }

  init() {
    signupText = tr('By signin up you agree to our');
    termsConditionText = tr('Terms of Services');
    andText = tr('and');
    privacyPolicyText = tr('Privacy Policy');
    notaAccountText = tr("Don't have an account?");

    update();
  }

  checkcontactExistOrNot(
      String contactno, BuildContext context, String type) async {
    try {
      global.showOnlyLoaderDialog();
      await apiHelper
          .checkContact(phoneno: contactno, logintype: type)
          .then((response) {
        dynamic rspnse1 = json.decode(response.body)['status'];
        log('checkcontactExistOrNot response status $rspnse1');
        String msg = jsonDecode(response.body)['message'];

        log('checkcontactExistOrNot response msg $msg');
        if (rspnse1 == 200) {
          String _loginotp = jsonDecode(response.body)['otp'];
          Get.to(() => LoginOtpScreen(
                mobileNumber: contactno,
                otpCode: _loginotp,
                countryCode: '+91',
              ));
        } else if (rspnse1 == 400) {
          global.hideLoader();
          global.showToast(message: msg);
        }
      });
    } catch (e) {
      print('Exception in checkcontactExistOrNot : - ${e.toString()}');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      // Force sign out to show the account picker every time
      await googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return null; // User canceled

      // Obtain the auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Error during Google sign-in: $e');
      return null;
    }
  }

  Future loginAstrologer({String? phoneNumber, String? email}) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          global.showOnlyLoaderDialog();
          global.getDeviceData();
          DeviceInfoLoginModel deviceInfoLoginModel = DeviceInfoLoginModel(
            appId: "2",
            appVersion: global.appVersion,
            deviceId: global.deviceId,
            deviceManufacturer: global.deviceManufacturer,
            deviceModel: global.deviceModel,
            fcmToken: global.fcmToken,
            deviceLocation: "",
          );

          await apiHelper
              .login(phoneNumber, email, deviceInfoLoginModel)
              .then((result) async {
            if (result.status == "200") {
              global.user = result.recordList;
              await global.sp!
                  .setString('currentUser', json.encode(global.user.toJson()));
              log('GLOBALLY SET VALUE ${global.user}');
              log('isverified  ${global.user.isVerified}');

              print('success');
              await global.getCurrentUserId();
              await chatController.getChatList(false);
              await callController.getCallList(true);
              await reportController.getReportList(false);
              await followingController.followingList(false);
              FutureBuilder(
                future: liveAstrologerController.endLiveSession(true),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      debugPrint('error ${snapshot.error}');
                    }
                    debugPrint('Live Session Ended Successfully');
                    return const SizedBox();
                  } else {
                    return const SizedBox();
                  }
                },
              );
              global.hideLoader();
              Get.to(() => const HomeScreen());
            } else if (result.status == "400") {
              // global.showToast(message: result.message.toString());
              ScaffoldMessenger.of(Get.context!).showSnackBar(
                SnackBar(
                  content: Text(result.message.toString()),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
              log('statuscode400 ${result.message.toString()}');
              global.hideLoader(); //ERROR OCCURED HIDE LOADER
              Get.offAll(() =>
                  const LoginScreen()); //REMOVE PREVIOUS SCREEN FROM STACK
            } else {
              global.showToast(message: result.message.toString());
              print('statuscode${result.status}');
              global.hideLoader();
              Get.offAll(() =>
                  const LoginScreen()); //REMOVE PREVIOUS SCREEN FROM STACK
            }
          });
        } else {
          global.showToast(message: 'No network connection!');
        }
      });
      update();
    } catch (e) {
      print('Exception - $screen - loginAstrologer(): ' + e.toString());
    }
  }
}

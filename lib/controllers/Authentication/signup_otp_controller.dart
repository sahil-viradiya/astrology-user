//ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';

import '../../services/apiHelper.dart';
import 'signup_controller.dart';

class SignupOtpController extends GetxController {
  String screen = 'signup_otp_controller.dart';
  final signupController = Get.find<SignupController>();
  double second = 0;
  int maxSecond = 60;
  Timer? time;
  APIHelper apiHelper = APIHelper();
  RxBool isLoading = false.obs;
  String countryCode = "+91";

  timer() {
    maxSecond = 60;
    time = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (maxSecond > 0) {
        maxSecond--;
        update();
      } else {
        time!.cancel();
      }
    });
  }

  updateCountryCode(String? value) {
    countryCode = value!;
    log('country code is $countryCode');
    update();
  }
}

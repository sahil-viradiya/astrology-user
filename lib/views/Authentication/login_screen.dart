// ignore_for_file: must_be_immutable, prefer_const_constructors, avoid_print

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/constants/imageConst.dart';
import 'package:astrowaypartner/controllers/Authentication/login_controller.dart';
import 'package:astrowaypartner/controllers/Authentication/login_otp_controller.dart';
import 'package:astrowaypartner/controllers/Authentication/signup_controller.dart';
import 'package:astrowaypartner/models/time_availability_model.dart';
import 'package:astrowaypartner/models/week_model.dart';
import 'package:astrowaypartner/views/Authentication/signup_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Drawer/Setting/privacy_policy_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Drawer/Setting/term_and_condition_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sizer/sizer.dart';

final initialPhone = PhoneNumber(isoCode: "IN");

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final signupController = Get.put(SignupController());
  final loginController = Get.put(LoginController());
  final loginOtpController = Get.put(LoginOtpController());
  static bool hasShownWarningDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasShownWarningDialog == false) {
        hasShownWarningDialog = true;
        global.warningDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        Get.back();
        SystemNavigator.pop();
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: 100.w,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 10.h,
                        backgroundImage: AssetImage('assets/images/splash.png'),
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Text(
                        global.appName,
                        style: Get.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  color: COLORS().primaryColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(children: [
                        _buildphoneNumberWidget(loginOtpController),

                        GestureDetector(
                          onTap: () async {
                            bool isValid = loginOtpController.validedPhone();
                            if (isValid) {
                              if (loginOtpController.cMobileNumber.text ==
                                  '9898989898') {
                                loginController.loginAstrologer(
                                    phoneNumber: '9898989898', email: '');
                              } else {
                                await loginController.checkcontactExistOrNot(
                                    loginOtpController.cMobileNumber.text
                                        .toString(),
                                    context,
                                    'login');
                              }
                            } else {
                              print("Snakcbar");
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Invalid Number"),
                                backgroundColor: Colors.red,
                              ));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                            child: Container(
                              height: 48,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    'SEND_OTP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ).tr(),
                                  Image.asset(
                                    IMAGECONST.arrowLeft,
                                    color: Colors.white,
                                    width: 7.w,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 2.h),
                        InkWell(
                          onTap: () async {
                            try {
                              final userCredential =
                                  await loginController.signInWithGoogle();
                              final user = userCredential!.user;
                              final emailid = user?.email;
                              await loginController.loginAstrologer(
                                  phoneNumber: '', email: emailid);
                            } catch (e) {
                              Get.snackbar(
                                'Login Failed',
                                e.toString(),
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                          child: Container(
                            height: 7.h,
                            margin: EdgeInsets.symmetric(horizontal: 5.w),
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10.sp)),
                            width: 100.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "assets/images/gmail.png",
                                  height: 4.h,
                                  width: 4.h,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Continue with Gmail',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: Colors.black, fontSize: 14.sp),
                                ),
                              ],
                            ),
                          ),
                        ),

                        //terms condition

                        GetBuilder<LoginController>(
                            builder: (logninController) {
                          return Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: '${loginController.signupText} ',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .titleMedium,
                                  children: [
                                    TextSpan(
                                      text: loginController.termsConditionText,
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 11,
                                        color: Colors.blue,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Get.to(
                                              () => TermAndConditionScreen());
                                          print("Terms and condition");
                                        },
                                    ),
                                    TextSpan(
                                      text: ' ${loginController.andText} ',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 11),
                                    ),
                                    TextSpan(
                                      text: loginController.privacyPolicyText,
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 9.sp,
                                          color: Colors.blue),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Get.to(() => PrivacyPolicyScreen());
                                          print("Privacy policy");
                                        },
                                    ),
                                  ],
                                ),
                              ));
                        }),
                      ]),
                      InkWell(
                        onTap: () {
                          signupController.week = [];
                          signupController.week!.add(Week(
                              day: "Sunday",
                              timeAvailabilityList: [
                                TimeAvailabilityModel(fromTime: "", toTime: "")
                              ]));
                          signupController.week!.add(Week(
                              day: "Monday",
                              timeAvailabilityList: [
                                TimeAvailabilityModel(fromTime: "", toTime: "")
                              ]));
                          signupController.week!.add(Week(
                              day: "Tuesday",
                              timeAvailabilityList: [
                                TimeAvailabilityModel(fromTime: "", toTime: "")
                              ]));
                          signupController.week!.add(Week(
                              day: "Wednesday",
                              timeAvailabilityList: [
                                TimeAvailabilityModel(fromTime: "", toTime: "")
                              ]));
                          signupController.week!.add(Week(
                              day: "Thursday",
                              timeAvailabilityList: [
                                TimeAvailabilityModel(fromTime: "", toTime: "")
                              ]));
                          signupController.week!.add(Week(
                              day: "Friday",
                              timeAvailabilityList: [
                                TimeAvailabilityModel(fromTime: "", toTime: "")
                              ]));
                          signupController.week!.add(Week(
                              day: "Saturday",
                              timeAvailabilityList: [
                                TimeAvailabilityModel(fromTime: "", toTime: "")
                              ]));
                          signupController.clearAstrologer();
                          Get.to(() => SignupScreen(),
                              routeName: "Signup Screen");
                        },
                        child: GetBuilder<LoginController>(
                            builder: (loginController) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.0, left: 2),
                            child: Center(
                                child: RichText(
                              text: TextSpan(
                                text: loginController.notaAccountText,
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .titleMedium,
                                children: <TextSpan>[
                                  TextSpan(
                                    text: " ${tr("signUp")}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          );
                        }),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container _buildphoneNumberWidget(LoginOtpController loginController) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.grey)),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: SizedBox(
          child: Theme(
            data: ThemeData(
              dialogTheme: DialogThemeData(
                contentTextStyle: TextStyle(color: Colors.white),
                backgroundColor: Colors.grey[800],
                surfaceTintColor: Colors.grey[800],
              ),
            ),
            //MOBILE
            child: SizedBox(
              child: InternationalPhoneNumberInput(
                spaceBetweenSelectorAndTextField: 0,
                maxLength: 10,
                scrollPadding: EdgeInsets.zero,
                textFieldController: loginController.cMobileNumber,
                inputDecoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Phone number',
                    hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500)),
                onInputValidated: (bool value) {
                  loginController.countryvalidator = value;
                  loginController
                      .update(); // If using GetX or setState if you're using StatefulWidget
                  print("Number valid? ${loginController.countryvalidator}");
                },
                selectorConfig: SelectorConfig(
                  trailingSpace: false,
                  leadingPadding: 2,
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: TextStyle(color: Colors.black),
                searchBoxDecoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(2.w)),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    hintText: "Search",
                    hintStyle: TextStyle(
                      color: Colors.black,
                    )),
                initialValue: initialPhone,
                formatInput: false,
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: false),
                inputBorder: InputBorder.none,
                onSaved: (PhoneNumber number) {
                  print('On Saved: ${number.dialCode}');
                  loginController.updateCountryCode(number.dialCode);
                  loginOtpController.update();
                },
                onFieldSubmitted: (value) {
                  print('On onFieldSubmitted: $value');
                },
                onInputChanged: (PhoneNumber number) {
                  print('On onInputChanged: ${number.dialCode}');
                  loginController.updateCountryCode(number.dialCode);
                  loginOtpController.update();
                },
                onSubmit: () {
                  print('On onSubmit:');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

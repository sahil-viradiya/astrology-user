// ignore_for_file: file_names, avoid_print, depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';

import 'package:astrowaypartner/controllers/HomeController/home_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/wallet_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;

import '../models/systemFlagModel.dart';
import '../models/user_model.dart';
import '../services/apiHelper.dart';
import '../views/Authentication/login_screen.dart';
import '../views/HomeScreen/home_screen.dart';
import 'HomeController/call_controller.dart';
import 'HomeController/chat_controller.dart';
import 'HomeController/live_astrologer_controller.dart';
import 'HomeController/report_controller.dart';
import 'following_controller.dart';
import 'networkController.dart';

class SplashController extends GetxController {
  // getxcontroller instance
  final networkController = Get.put(NetworkController());
  final chatController = Get.find<ChatController>();
  final callController = Get.find<CallController>();
  final reportController = Get.put(ReportController());
  final followingController = Get.put(FollowingController());
  final liveAstrologerController = Get.put(LiveAstrologerController());
  String? appShareLinkForLiveSreaming;
  final homecontroller = Get.find<HomeController>();
  final walletController = Get.find<WalletController>();
  final apiHelper = APIHelper();
  CurrentUser? currentUser;
  //Variables
  var systemFlag = <SystemFlag>[];
  RxBool isDataLoaded = false.obs;
  String? version;
  String currentLanguageCode = 'en';

  @override
  void onInit() async {
    ever(networkController.connectionStatus, (status) {
      debugPrint('status init $status');

      if (status > 0) {
        _init();
      } else {
        debugPrint('not connected init');
        Get.snackbar(
          "Warning",
          "No Internet Connection",
          snackPosition: SnackPosition.BOTTOM,
          messageText: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.signal_wifi_off,
                color: Colors.white,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                  ),
                  child: const Text(
                    "No Internet Available",
                    textAlign: TextAlign.start,
                  ).tr(),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.white),
                  height: 30,
                  width: 55,
                  child: Center(
                    child: Text(
                      "Retry",
                      style:
                          TextStyle(color: Theme.of(Get.context!).primaryColor),
                    ).tr(),
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(days: 1),
          backgroundColor: Theme.of(Get.context!).primaryColor,
          colorText: Colors.white,
        );
      }
    });
    super.onInit();
  }

  _init() async {
    try {
      Obx(() {
        debugPrint('test outside ${networkController.connectionStatus.value}');
        return const SizedBox();
      });

      await global.checkBody().then(
        (networkResult) async {
          print('after check body');
          print('$networkResult');
          if (networkResult) {
            if (networkController.connectionStatus.value != 0) {
              await performApiCalls();
            } else {
              global.showToast(message: "No Network Available");
            }
          } else {
            global.showToast(message: "No Network Available");
          }
        },
      );
    } catch (err) {
      global.printException("SplashController", "_init", err);
    }

    String? fcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM TOKEN $fcmToken');
  }

  getSystemList() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getSystemFlag().then((result) {
            print("kjansdkj");
            print("kjansdkj ${result.status}");
            // if (result.status == "200") {
            systemFlag = result.recordList;
            update();
            // } else {
            //   if (global.currentUserId != null) {
            //     global.showToast(message: "System flag not found");
            //   }
            // }
          });
        }
      });
    } catch (e) {
      print('Exception in getSystemList():$e');
    }
  }

  performApiCalls() async {
    await apiHelper.getMasterTableData().then(
      (apiResult) async {
        print("jansjkn ${apiResult.status}");
        if (apiResult.status == "200") {
          await global.getDeviceData();
          await getSystemList();
          global.appName =
              global.getSystemFlagValue(global.systemFlagNameList.appName);
          global.spLanguage = await SharedPreferences.getInstance();
          currentLanguageCode =
              global.spLanguage!.getString('currentLanguage') ?? 'en';
          update();
          global.getMasterTableDataModelList = apiResult.recordList;
          global.astrologerCategoryModelList =
              global.getMasterTableDataModelList.astrologerCategory;
          global.skillModelList = global.getMasterTableDataModelList.skill;
          global.allSkillModelList =
              global.getMasterTableDataModelList.allskill;
          global.languageModelList =
              global.getMasterTableDataModelList.language;
          global.assistantPrimarySkillModelList =
              global.getMasterTableDataModelList.assistantPrimarySkill;
          global.assistantAllSkillModelList =
              global.getMasterTableDataModelList.assistantAllSkill;
          global.assistantLanguageModelList =
              global.getMasterTableDataModelList.assistantLanguage;
          global.mainSourceBusinessModelList =
              global.getMasterTableDataModelList.mainSourceBusiness;
          global.highestQualificationModelList =
              global.getMasterTableDataModelList.highestQualification;
          global.degreeDiplomaList =
              global.getMasterTableDataModelList.qualifications;
          global.jobWorkingList = global.getMasterTableDataModelList.jobs;
        }
      },
    );
    global.sp = await SharedPreferences.getInstance();
    dev.log('global sp is get ${global.sp!.getString("currentUser")}');
    if (global.sp!.getString("currentUser") != null) {
      await apiHelper.validateSession().then((result) async {
        if (result.status == "200") {
          global.user = result.recordList;
          global.user.token = global.user.sessionToken!.split(" ")[1];
          await global.sp!
              .setString('currentUser', json.encode(global.user.toJson()));
          if (global.user.id != null) {
            global.showOnlyLoaderDialog(); //show prgoessn dialog
            await global.getCurrentUserId();
            //Lazy loading
            chatController.chatList.clear();
            callController.callList.clear();
            reportController.reportList.clear();
            followingController.followerList.clear();

            debugPrint(
                'net is for >0 working ${networkController.connectionStatus.value}');
            Future.wait<void>([
              chatController.getChatList(false),
              callController.getCallList(false),
              reportController.getReportList(false),
              followingController.followingList(false)
            ]);

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

            global.hideLoader(); //hide  prgoessn dialog

            getinitialmsg();
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await Future.delayed(const Duration(seconds: 2));
              _loadSavedData();
            });
          } else {
            Get.off(() => const LoginScreen(), routeName: "LoginScreen");
          }
        } else {
          Get.off(() => const LoginScreen(), routeName: "LoginScreen");
        }
      });
    } else {
      Get.off(() => const LoginScreen(), routeName: "LoginScreen");
    }
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isacceptedcall = prefs.getBool('is_accepted');
    print('is accepted or not $isacceptedcall');
    if (isacceptedcall == true) {
      String? dataaccepted = prefs.getString('is_accepted_data');
      if (dataaccepted!.isNotEmpty) {
        await prefs.setBool('is_accepted', false);
        print('is accepted dataaccepted $dataaccepted}');
        callAccept(jsonDecode(dataaccepted));
        await prefs.setString('is_accepted_data', '');
      }
    } else {
      debugPrint('is accepted is not either false or not set ');
      await prefs.setBool('is_accepted', false);
      await prefs.setString('is_accepted_data', '');
    }

    bool? isrejectedcall = prefs.getBool('is_rejected');
    if (isrejectedcall == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_accepted', false);
      await prefs.setString('is_accepted_data', '');
    }
  }

  void getinitialmsg() async {
    debugPrint('_message is getinitialmsg');

    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {
        if (message.data.isNotEmpty) {
          debugPrint('getInitialMessage data is ${message.data}');

          try {
            var messageData = json.decode((message.data['body']));
            log('notification body $messageData');
            if (messageData!["notificationType"] == 2) {
              await walletController.getAmountList();
              walletController.update();

              callController.callList.clear();
              callController.update();
              await callController.getCallList(false);
              callController.update();

              homecontroller.homeTabIndex = 1; //pageview index
              homecontroller.isSelectedBottomIcon = 1;
              homecontroller.tabController!.animateTo(1);
              homecontroller.update();
              Get.offAll(const HomeScreen());
            } else {
              Get.offAll(const HomeScreen());
            }
          } on Exception catch (e) {
            log('notification body $e');
            Get.offAll(const HomeScreen());
          }
        } else {
          Get.offAll(const HomeScreen());
        }

        //call audiovideo
      } else {
        debugPrint('firebase service no data ');
        Get.offAll(const HomeScreen());
      }
    });
  }
}

@pragma('vm:entry-point')
void callAccept(Map<String, dynamic> extraData) async {
  print('extra call astrologerId ${extraData['astrologerId']}');

  final callController = Get.find<CallController>();
  if (extraData["notificationType"] == 2) {
    callController.callList.clear();
    callController.update();
    await callController.getCallList(false);
    callController.update();

    if (extraData['call_type'] == 10) {
      callController.acceptCallRequest(
        extraData['callId'],
        extraData['profile'],
        extraData['name'],
        extraData['id'],
        extraData['fcmToken'],
        extraData['call_duration'].toString(),
      );
    } else if (extraData['call_type'] == 11) {
      callController.acceptVideoCallRequest(
        extraData['callId'],
        extraData['profile'],
        extraData['name'],
        extraData['id'],
        extraData['fcmToken'],
        extraData['call_duration'].toString(),
      );
    }
  }
  // if (extraData['call_type'] == 10) {
  //   await callController.acceptedCall(extraData["callId"]);
  //   Get.to(
  //     () => AcceptCallScreen(
  //       astrologerId: extraData["astrologerId"],
  //       astrologerName: extraData["astrologerName"] == null
  //           ? "Astrologer"
  //           : extraData["astrologerName"],
  //       astrologerProfile:
  //           extraData["profile"] == null ? "" : extraData["profile"],
  //       token: extraData["token"],
  //       callChannel: extraData["channelName"],
  //       callId: extraData["callId"],
  //       duration: extraData['call_duration'].toString(),
  //     ),
  //   );
  // } else if (extraData['call_type'] == 11) {
  //   Get.to(() => OneToOneLiveScreen(
  //         channelname: extraData["channelName"],
  //         callId: extraData["callId"],
  //         fcmToken: extraData["token"].toString(),
  //         end_time: extraData['call_duration'].toString(),
  //       ));
  // }
}

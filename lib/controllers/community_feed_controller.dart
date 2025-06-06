import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zenactive/models/my_friend_model.dart';
import 'package:zenactive/models/post_model.dart';
import 'package:zenactive/models/request_model.dart';
import 'package:zenactive/models/user_list_mdoel.dart';
import 'package:zenactive/services/api_checker.dart';
import 'package:zenactive/services/api_client.dart';
import 'package:zenactive/services/api_constant.dart';
import 'package:zenactive/utils/app_constants.dart';
import 'package:zenactive/utils/prefs_helper.dart';
import 'package:zenactive/utils/uitls.dart';

class CommunityFeedController extends GetxController implements GetxService {
  String title = "Community Screen";
  RxBool isLoading = false.obs;
  RxList<PostModel> postList = <PostModel>[].obs;
  RxList<UserListModel> userList = <UserListModel>[].obs;
  RxList<MyFriendModel> myFriends = <MyFriendModel>[].obs;
  RxList<RequestModel> requestList = <RequestModel>[].obs;
  RxList<String> activeIds = <String>[].obs;

  final TextEditingController postController = TextEditingController();
  void getAllPost() async {
    isLoading.value = true;
    final bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $bearerToken',
    };
    try {
      final response = await ApiClient.getData(
        ApiConstant.allPost,
        headers: headers,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          postList.value = response.body["data"]
              .map<PostModel>((e) => PostModel.fromJson(e))
              .toList();
          isLoading.value = false;
        } catch (e) {
          debugPrint('Model Convertion Error: ${e.toString()}');
          isLoading.value = false;
        }
      }
    } catch (e) {
      debugPrint('------------${e.toString()}');
      isLoading.value = false;
    }
    isLoading.value = false;
  }

  void getAllFriend() async {
    isLoading.value = true;
    final bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $bearerToken',
    };
    try {
      final response = await ApiClient.getData(
        ApiConstant.getAllFriend,
        headers: headers,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          userList.value = response.body["data"]
              .map<UserListModel>((e) => UserListModel.fromJson(e))
              .toList();
          isLoading.value = false;
        } catch (e) {
          debugPrint('Model Convertion Error: ${e.toString()}');
          isLoading.value = false;
        }
      }
    } catch (e) {
      debugPrint('------------${e.toString()}');
      isLoading.value = false;
    }
    isLoading.value = false;
  }

  void getMyFiends() async {
    isLoading.value = true;
    final bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $bearerToken',
    };
    try {
      final response = await ApiClient.getData(
        ApiConstant.getMyFriends,
        headers: headers,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          myFriends.value = response.body["data"]
              .map<MyFriendModel>((e) => MyFriendModel.fromJson(e))
              .toList();
          isLoading.value = false;
        } catch (e) {
          debugPrint('Model Convertion Error: ${e.toString()}');
          isLoading.value = false;
        }
      }
    } catch (e) {
      debugPrint('------------${e.toString()}');
      isLoading.value = false;
    }
    isLoading.value = false;
  }

  void getRequsted({required String type}) async {
    isLoading.value = true;
    final bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $bearerToken',
    };
    final params = {
      'type': type,
    };
    try {
      final response = await ApiClient.getData(
        ApiConstant.requestedList,
        headers: headers,
        query: params,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          requestList.value = response.body["data"]
              .map<RequestModel>((e) => RequestModel.fromJson(e))
              .toList();
          isLoading.value = false;
        } catch (e) {
          debugPrint('Model Convertion Error: ${e.toString()}');
          isLoading.value = false;
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint('------------${e.toString()}');
      isLoading.value = false;
    }
    isLoading.value = false;
  }

  void sendRequest({required String userId}) async {
    isLoading.value = true;
    final bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    };
    Map<String, String> body = {
      "friendId": userId,
    };
    try {
      final response = await ApiClient.postData(
        ApiConstant.sendRequest,
        jsonEncode(body),
        headers: headers,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          getAllFriend();
        } catch (e) {
          debugPrint('Model Convertion Error: ${e.toString()}');
          isLoading.value = false;
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint('------------${e.toString()}');
      isLoading.value = false;
    }
    isLoading.value = false;
  }

  void confirmFriendRequest({required String userId}) async {
    isLoading.value = true;
    final bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    };
    Map<String, String> body = {
      "friendId": userId,
    };
    try {
      final response = await ApiClient.patchData(
        ApiConstant.acceptRequest,
        jsonEncode(body),
        headers: headers,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          getRequsted(type: "requestedList");
        } catch (e) {
          debugPrint('Model Convertion Error: ${e.toString()}');
          isLoading.value = false;
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint('------------${e.toString()}');
      isLoading.value = false;
    }
    isLoading.value = false;
  }

  postwithImage({XFile? pickedFile, String? text}) async {
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);
      List<MultipartBody> multipartBody = [MultipartBody("image", file)];
      Map<String, String> body = {
        "data": jsonEncode({
          "text": text ?? "",
        })
      };
      final headers = {
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $bearerToken',
      };
      try {
        final response = await ApiClient.postMultipartData(
          ApiConstant.addPost,
          body,
          multipartBody: multipartBody,
          headers: headers,
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.back();
          showSnackBar(
              message: response.body["message"],
              isSucess: response.body["status"] == 200);
        } else {
          ApiChecker.checkApi(response);
        }
      } catch (e) {
        debugPrint('Model Convertion Error: ${e.toString()}');
        isLoading.value = false;
      }
    }
  }

  post(String text) async {
    final bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);
    List<MultipartBody> multipartBody = [];
    Map<String, String> body = {
      "data": jsonEncode({
        "text": text,
      })
    };
    final headers = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $bearerToken',
    };
    try {
      final response = await ApiClient.postMultipartData(
        ApiConstant.addPost,
        body,
        multipartBody: multipartBody,
        headers: headers,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        showSnackBar(
            message: response.body["message"],
            isSucess: response.body["status"] == 200);
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint('Model Convertion Error: ${e.toString()}');
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    debugPrint("On Init  $title");
    getAllPost();
    super.onInit();
  }

  //oneclose
  @override
  void onClose() {
    debugPrint("On Close  $title");
    super.onClose();
  }

  @override
  void onReady() {
    debugPrint("On onReady  $title");
    super.onReady();
  }
}

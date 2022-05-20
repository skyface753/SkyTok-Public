// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/*
import 'package:skytok_flutter/services/api_requests.dart' as api;
*/

// String serverUrl = "http://localhost";
String protocol = "http";
String iporhost = "192.168.178.130";
String serverUrl = "$protocol://$iporhost";
// String serverUrl = "http://192.168.178.130";
String token = "";
int myId = 0;
String? myPicturePath;
String myUsername = "";
Map<String, String> deviceInfo = {};

_getDeviceInfo() async {
  if (kIsWeb) {
    deviceInfo['Platform'] = 'web';
  } else {
    deviceInfo['deviceOS'] = Platform.operatingSystem;
    if (Platform.isAndroid) {
      deviceInfo['Platform'] = 'android';
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      deviceInfo['Device'] = androidInfo.device ?? 'unknown';
      deviceInfo['Manufacturer'] = androidInfo.manufacturer ?? 'unknown';
      deviceInfo['Model'] = androidInfo.model ?? 'unknown';
      deviceInfo['Product'] = androidInfo.product ?? 'unknown';
      deviceInfo['Version'] = androidInfo.version.release ?? 'unknown';
    } else if (Platform.isIOS) {
      deviceInfo['Platform'] = 'ios';
      IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
      deviceInfo['Device'] = iosInfo.utsname.machine ?? 'unknown';
      deviceInfo['Model'] = iosInfo.model ?? 'unknown';
      deviceInfo['Product'] = iosInfo.utsname.machine ?? 'unknown';
      deviceInfo['Version'] = iosInfo.systemVersion ?? 'unknown';
    } else {
      deviceInfo['Platform'] = 'unknown';
      deviceInfo['Device'] = 'unknown';
      deviceInfo['Manufacturer'] = 'unknown';
      deviceInfo['Model'] = 'unknown';
      deviceInfo['Product'] = 'unknown';
      deviceInfo['Version'] = 'unknown';
    }
  }
}

Future requestApi(String url, Map<String, String> jsonEncodedBody,
    BuildContext context) async {
  await _getDeviceInfo();
  jsonEncodedBody['deviceInfo'] = deviceInfo.toString();
  // inspect(jsonEncodedBody);

  try {
    var apiUrl = serverUrl + url;
    // Starttime for request in ms
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var response = await http
        .post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token,
          },
          body: json.encode(jsonEncodedBody),
        )
        .timeout(const Duration(seconds: 10));
    // print("Response: " + response.body);
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        // ignore: prefer_typing_uninitialized_variables
        var returnResponse;
        try {
          returnResponse = json.decode(response.body);
        } catch (e) {
          returnResponse = response.body;
        }
        return returnResponse;
      } else {
        throw Exception("No Response from Server");
      }
    } else if (response.statusCode == 400) {
      // 400 Bad Request - Invalid Input  // Logout

      return null;
    } else if (response.statusCode == 401) {
      return null;
    }
  } catch (e) {
    return null;
  }
}

class Api {
  String getToken() {
    return token;
  }

  setData(String gettoken, int getuserId, String username) {
    token = gettoken;
    myId = getuserId;
    myUsername = username;
  }

  Future sendAppDuration(DateTime startTime, DateTime endTime, int duration,
      int pause_duration, BuildContext context) {
    Map<String, String> jsonEncodedBody = {
      'start_time': startTime.toString(),
      'end_time': endTime.toString(),
      'duration': duration.toString(),
      'pause_duration': pause_duration.toString(),
    };
    return requestApi('/analytics/send/duration', jsonEncodedBody, context);
  }

  Future getUserVideos(BuildContext context) async {
    var response = await requestApi(
        "/videos/proposals", <String, String>{"userId": "1"}, context);
    // inspect(response);
    return response["response"];
  }

  Future login(
      BuildContext context, String usernameoremail, String password) async {
    var response = await requestApi(
        "/login",
        <String, String>{
          "usernameOrEmail": usernameoremail,
          "password": password
        },
        context);
    // print("Response in API: " + response.toString());
    if (response == null) {
      return false;
    }
    return response["response"];
  }

  Future getCommentsForVideo(BuildContext context, int video_id) async {
    var response = await requestApi("/comments/getbyVideoId",
        <String, String>{"video_id": video_id.toString()}, context);

    return response["response"];
  }

  Future getUserInfo(BuildContext context, String? username) async {
    var response = await requestApi("/users/info",
        <String, String>{"for_user_name": username ?? ""}, context);
    return response["response"];
  }

  Future getLikedForUser(BuildContext context, String? username) async {
    var response = await requestApi("/videos/liked/get",
        <String, String>{"for_user_name": username ?? ""}, context);
    return response["response"];
  }

  Future followUser(BuildContext context, int user_id) async {
    var response = await requestApi("/followers/new",
        <String, String>{"to_user_id": user_id.toString()}, context);
    return response["response"];
  }

  Future unFollowUser(BuildContext context, int user_id) async {
    var response = await requestApi("/followers/delete",
        <String, String>{"to_user_id": user_id.toString()}, context);
    return response["response"];
  }

  Future trendingTags(BuildContext context) async {
    var response = await requestApi(
        "/tags/trending", <String, String>{"to_user_id": ""}, context);
    // print("Response: " + response.toString());
    return response["response"];
  }

  Future followerSuggestions(BuildContext context) async {
    var response = await requestApi(
        "/followers/sugestions", <String, String>{"": ""}, context);
    // print("Response: " + response.toString());
    return response["response"];
  }

  Future getAnalytics(BuildContext context) async {
    var response =
        await requestApi("/analytics/get", <String, String>{"": ""}, context);
    // print("Response: " + response.toString());
    return response["response"];
  }

  Future joinLive(BuildContext context, int user_id) async {
    var response = await requestApi("/live/join",
        <String, String>{"stream_user_id": user_id.toString()}, context);
    return response["response"];
  }

  Future startLive(BuildContext context) async {
    var response =
        await requestApi("/live/start", <String, String>{"": ""}, context);
    return response["response"];
  }

  Future stopLive(BuildContext context) async {
    var response =
        await requestApi("/live/stop", <String, String>{"": ""}, context);
    return response["response"];
  }

  Future countLive(BuildContext context, String stream_name) async {
    var response = await requestApi(
        "/live/views", <String, String>{"stream_name": stream_name}, context);
    return response["response"];
  }
}

Future shareVideo(
    BuildContext context, int video_id, int suggestionType) async {
  var response = await requestApi(
      "/videos/share",
      <String, String>{
        "video_id": video_id.toString(),
        "suggestion_type": suggestionType.toString()
      },
      context);
  return response;
}

Future likeVideo(BuildContext context, int video_id, int suggestionType) async {
  var response = await requestApi(
      "/videos/liked",
      <String, String>{
        "video_id": video_id.toString(),
        "suggestionType": suggestionType.toString()
      },
      context);
  return response;
}

Future unlikeVideo(BuildContext context, int video_id) async {
  var response = await requestApi("/videos/unliked",
      <String, String>{"video_id": video_id.toString()}, context);
  return response;
}

Future watchedVideo(BuildContext context, int video_id, int duration) async {
  var response = await requestApi(
      "/videos/watched",
      <String, String>{
        "video_id": video_id.toString(),
        "length": duration.toString()
      },
      context);
  return response;
}

Future getVideosForUser(BuildContext context, String? forUser) async {
  // print("ForUser: " + forUser!);
  var response = await requestApi(
      "/videos/forUser", <String, String>{"for_user": forUser ?? ""}, context);
  // print(response["response"]);
  return response["response"];
}

Future createComment(BuildContext context, int video_id, String comment,
    int suggestionType) async {
  var response = await requestApi(
      "/comments/create",
      <String, String>{
        "video_id": video_id.toString(),
        "comment": comment,
        "suggestion_type": suggestionType.toString()
      },
      context);
  return response;
}

Future likeComment(BuildContext context, int comment_id) async {
  var response = await requestApi("/comments/liked",
      <String, String>{"comment_id": comment_id.toString()}, context);
  print(response);
  return response;
}

Future unlikeComment(BuildContext context, int comment_id) async {
  var response = await requestApi("/comments/unliked",
      <String, String>{"comment_id": comment_id.toString()}, context);
  return response;
}

Future getChats(BuildContext context) async {
  var response = await requestApi(
      "/messages/chats/get", <String, String>{"user_id": "1"}, context);
  return response["response"];
}

Future getMessages(BuildContext context, int other_user_id) async {
  var response = await requestApi("/messages/get",
      <String, String>{"other_user_id": other_user_id.toString()}, context);
  return response["response"];
}

Future sendMessage(BuildContext context, int other_user_id, String message,
    int? video_id) async {
  var response = await requestApi(
      "/messages/send",
      <String, String>{
        "receiver_id": other_user_id.toString(),
        "message": message,
        "video_id": video_id?.toString() ?? ""
      },
      context);
  return response;
}

Future search(BuildContext context, String search) async {
  var response = await requestApi(
      "/search", <String, String>{"searchTerm": search}, context);
  return response["response"];
}

Future getVideosForTag(BuildContext context, String tagName) async {
  print("TagName: " + tagName);
  var response = await requestApi(
      "/tags/get/video", <String, String>{"tag_name": tagName}, context);
  return response["response"];
}

Future getMyFollowing(BuildContext context) async {
  var response = await requestApi(
      "/followers/get/Following", <String, String>{"user_id": "1"}, context);
  // inspect(response);
  return response["response"];
}

Future getNotifications(BuildContext context) async {
  var response = await requestApi(
      "/notifications/get", <String, String>{"user_id": "1"}, context);
  return response["response"];
}

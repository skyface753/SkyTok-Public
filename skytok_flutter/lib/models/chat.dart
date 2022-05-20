import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:skytok_flutter/models/video.dart';
import 'package:skytok_flutter/screens/messages_screen.dart';

class Chat {
  int userId;
  String latest;
  String username;
  String message;
  String unReaded;
  String? picturePath;
  // List<ChatMessage>? messages = [];

  Chat(this.userId, this.latest, this.username, this.message, this.unReaded,
      this.picturePath);

  Chat.fromJson(Map json)
      : userId = json['user_id'],
        latest = json['latest'],
        username = json['username'],
        message = json['message'],
        unReaded = json['unReaded'],
        picturePath = json['picturePath'];

  Map toJson() => {
        'user_id': userId,
        'latest': latest,
        'username': username,
        'message': message,
        'unReaded': unReaded,
        'picturePath': picturePath,
      };

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'latest': latest,
        'username': username,
        'message': message,
        'unReaded': unReaded,
        'picturePath': picturePath,
      };
}

class ChatMessage {
  int id;
  int fromUserID;
  int toUserID;
  String message;
  DateTime timestamp;
  Video? video;
  String? recordPath;
  GlobalKey<AudioMessageState>? audioMessageKey;

  ChatMessage(this.id, this.fromUserID, this.toUserID, this.message,
      this.timestamp, this.video, this.recordPath);

  ChatMessage.fromJson(Map json)
      : id = json['id'].runtimeType == int ? json['id'] : int.parse(json['id']),
        fromUserID = json['from_user_id'],
        toUserID = json['to_user_id'],
        message = json['message'],
        timestamp = DateTime.parse(json['timestamp']),
        video = json['video'] != null ? Video.fromJson(json['video']) : null,
        recordPath = json['record_path'],
        audioMessageKey =
            json['record_path'] != null ? GlobalKey<AudioMessageState>() : null;

  Map toJson() {
    return {
      'id': id,
      'from_user_id': fromUserID,
      'to_user_id': toUserID,
      'message': message,
      'timestamp': timestamp.toString(),
      'video': video?.toJson(),
      'record_path': recordPath,
    };
  }
}

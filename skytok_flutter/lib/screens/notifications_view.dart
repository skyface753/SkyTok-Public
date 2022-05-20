import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skytok_flutter/models/notification.dart';
import 'package:skytok_flutter/services/api_requests.dart' as api;
import 'package:timeago/timeago.dart' as timeago;

class NotificationsView extends StatefulWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  _NotificationsViewState createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    _getNotifications();
    // Refresh the notifications every 10 seconds

    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (kDebugMode) {
        return;
      }
      try {
        _getNotifications();
      } catch (e) {
        print("Error in getting notifications");
      }
    });
  }

  bool isLoaded = false;
  List<NotificationModel> _notifications = [];
  List<FollowerNotificationModel> _followerNotifications = [];
  List<LikeNotification> _likeNotifications = [];
  List<CommentNotification> _commentNotifications = [];

  _getNotifications() async {
    var response = await api.getNotifications(context);
    if (response != null) {
      _notifications.clear();
      _followerNotifications.clear();
      _likeNotifications.clear();
      _commentNotifications.clear();
      for (var notification in response) {
        if (notification['type'] == 0) {
          _followerNotifications
              .add(FollowerNotificationModel.fromJson(notification));
        } else if (notification['type'] == 1) {
          _likeNotifications.add(LikeNotification.fromJson(notification));
        } else if (notification['type'] == 2) {
          _commentNotifications.add(CommentNotification.fromJson(notification));
        }
      }
      _notifications.addAll(_followerNotifications);
      _notifications.addAll(_likeNotifications);
      _notifications.addAll(_commentNotifications);
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      setState(() {
        isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              Navigator.pushNamed(context, '/chats');
            },
          ),
        ],
      ),
      body: isLoaded
          ? ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                DateTime notificationDate = _notifications[index].timestamp;
                final timeAgo =
                    timeago.format(notificationDate, locale: 'en_short');

                switch (_notifications[index].type) {
                  //TODO: Ontap
                  case 0: // New Follower
                    FollowerNotificationModel currFollowerNotification =
                        _followerNotifications
                            .where(
                                (element) => element == _notifications[index])
                            .first;
                    return ListTile(
                        title: Text(currFollowerNotification.newFollower),
                        subtitle: Row(children: [
                          const Text("followed you. "),
                          // SizedBox(width: 5),
                          Text(timeAgo,
                              style: TextStyle(color: Colors.grey[600]))
                        ]),
                        leading: getCircleAvatar(
                            currFollowerNotification.picturePath),
                        trailing: Container(
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              // borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Padding(
                                padding: EdgeInsets.all(5),
                                child: Text("TEST"))));

                  case 1: // New Like
                    LikeNotification currLikeNotification = _likeNotifications
                        .where((element) => element == _notifications[index])
                        .first;
                    return ListTile(
                      title: Text(currLikeNotification.newLikeUser),
                      subtitle: Row(children: [
                        Text(' has liked your video. '),
                        Text(timeAgo, style: TextStyle(color: Colors.grey[600]))
                      ]),
                      leading:
                          getCircleAvatar(currLikeNotification.picturePath),
                      trailing:
                          getVideoThumbnail(currLikeNotification.thumbnailPath),
                    );
                  case 2: // New Comment
                    CommentNotification currCommentNotification =
                        _commentNotifications
                            .where(
                                (element) => element == _notifications[index])
                            .first;
                    return ListTile(
                      leading:
                          getCircleAvatar(currCommentNotification.picturePath),
                      title: Text(currCommentNotification.newCommentUser),
                      subtitle: Row(
                        children: [
                          Text(' has commented on your video. '),
                          Text(timeAgo,
                              style: TextStyle(color: Colors.grey[600]))
                        ],
                      ),
                      trailing: getVideoThumbnail(
                          currCommentNotification.thumbnailPath),
                    );
                  default:
                    return Container();
                }
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget getCircleAvatar(String? picturePath) {
    if (picturePath != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(api.serverUrl + "/" + picturePath),
      );
    } else {
      return const CircleAvatar(
        backgroundImage: AssetImage("assets/images/avatar.png"),
      );
    }
  }

  Widget getVideoThumbnail(String thumbnailPath) {
    return Image.network(api.serverUrl + "/" + thumbnailPath);
  }
}

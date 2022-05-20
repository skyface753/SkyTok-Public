class NotificationModel {
  int forUserID;
  int type;
  DateTime timestamp;

  NotificationModel(
    this.forUserID,
    this.type,
    this.timestamp,
  );

  NotificationModel.fromJson(Map json)
      : forUserID = json['for_user_id'],
        type = json['type'],
        timestamp = DateTime.parse(json['timestamp']);

  Map toJson() {
    return {
      'for_user_id': forUserID,
      'type': type,
      'timestamp': timestamp.toString(),
    };
  }

  // String getFollowerID(){
  //   this.newFollowerID;
  // }
}

class FollowerNotificationModel extends NotificationModel {
  String newFollower;
  int newFollowerID;
  String? picturePath;

  FollowerNotificationModel(
    this.newFollower,
    this.newFollowerID,
    int forUserID,
    int type,
    DateTime timestamp,
    this.picturePath,
  ) : super(forUserID, type, timestamp);

  FollowerNotificationModel.fromJson(Map json)
      : newFollower = json['newFollower'],
        picturePath = json['picturePath'],
        newFollowerID = json['newFollowerID'],
        super.fromJson(json);

  @override
  Map toJson() {
    return {
      'newFollower': newFollower,
      'newFollowerID': newFollowerID,
      'picturePath': picturePath,
      'forUserID': forUserID,
      'type': type,
      'timestamp': timestamp.toString(),
    };
  }
}

class LikeNotification extends NotificationModel {
  int newLikeUserID;
  String newLikeUser;
  String? picturePath;
  String thumbnailPath;
  int newLikeVideoID;

  LikeNotification(
    this.newLikeUserID,
    this.newLikeUser,
    int forUserID,
    int type,
    DateTime timestamp,
    this.picturePath,
    this.thumbnailPath,
    this.newLikeVideoID,
  ) : super(forUserID, type, timestamp);

  LikeNotification.fromJson(Map json)
      : newLikeUserID = json['newLikeUserID'],
        newLikeUser = json['newLikeUser'],
        picturePath = json['picturePath'],
        thumbnailPath = json['thumbnailPath'],
        newLikeVideoID = json['newLikeVideoID'],
        super.fromJson(json);

  @override
  Map toJson() {
    return {
      'newLikeUserID': newLikeUserID,
      'newLikeUser': newLikeUser,
      'picturePath': picturePath,
      'thumbnailPath': thumbnailPath,
      'newLikeVideoID': newLikeVideoID,
      // super.toJson();
      'for_user_id': forUserID,
      'type': type,
      'timestamp': timestamp.toString(),
    };
  }
}

class CommentNotification extends NotificationModel {
  int newCommentUserID;
  String newCommentUser;
  String? picturePath;
  String thumbnailPath;
  int newCommentVideoID;

  CommentNotification(
    this.newCommentUserID,
    this.newCommentUser,
    int forUserID,
    int type,
    DateTime timestamp,
    this.picturePath,
    this.thumbnailPath,
    this.newCommentVideoID,
  ) : super(forUserID, type, timestamp);

  CommentNotification.fromJson(Map json)
      : newCommentUserID = json['newCommentUserID'],
        newCommentUser = json['newCommentUser'],
        picturePath = json['picturePath'],
        thumbnailPath = json['thumbnailPath'],
        newCommentVideoID = json['newCommentVideoID'],
        super.fromJson(json);

  @override
  Map toJson() {
    return {
      'newCommentUserID': newCommentUserID,
      'newCommentUser': newCommentUser,
      'picturePath': picturePath,
      'thumbnailPath': thumbnailPath,
      'newCommentVideoID': newCommentVideoID,
      'for_user_id': forUserID,
      'type': type,
      'timestamp': timestamp.toString(),
    };
  }
}

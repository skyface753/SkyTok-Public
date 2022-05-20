class Video {
  int id;
  // String? path;
  String thumbnailPath;
  int length;
  // ignore: non_constant_identifier_names
  int user_id;
  String descryption;
  String username;
  int commentCount;
  int likeCount;
  bool userLikedTheVideo;
  int shares;
  String? userPicturePath;
  bool userFollowing;
  int type;
  int privacyId;
  int watchedCount;

  Video(
      this.id,
      // this.path,
      this.thumbnailPath,
      this.length,
      this.user_id,
      this.descryption,
      this.username,
      this.commentCount,
      this.likeCount,
      this.userLikedTheVideo,
      this.shares,
      this.userPicturePath,
      this.userFollowing,
      this.type,
      this.privacyId,
      this.watchedCount);

  Video.fromJson(Map json)
      : id = json['id'],
        // path = json['path'],
        thumbnailPath = json['thumbnailPath'],
        length = json['length'],
        user_id = json['user_id'],
        descryption = json['descryption'],
        username = json['username'],
        commentCount = json['commentCount'],
        likeCount = json['likeCount'],
        userLikedTheVideo = json['userLikedTheVideo'],
        shares = json['shares'],
        userPicturePath = json['userPicturePath'],
        userFollowing = json['userFollowing'],
        type = json['type'],
        privacyId = json['privacy_id'],
        watchedCount = json['watchedCount'];

  Map toJson() {
    return {
      'id': id,
      // 'path': path,
      'thumbnailPath': thumbnailPath,
      'length': length,
      'user_id': user_id,
      'descryption': descryption,
      'username': username,
      'commentCount': commentCount,
      'likeCount': likeCount,
      'userLikedTheVideo': userLikedTheVideo,
      'shares': shares,
      'userPicturePath': userPicturePath,
      'userFollowing': userFollowing,
      'type': type,
      'privacy_id': privacyId,
      'watchedCount': watchedCount
    };
  }
}

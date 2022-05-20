class Comment {
  int id;
  int video_id;
  int user_id;
  String comment;
  DateTime timestamp;
  String username;
  int likeCount;
  bool liked;

  Comment(this.id, this.video_id, this.user_id, this.comment, this.timestamp,
      this.username, this.likeCount, this.liked);

  Comment.fromJson(Map json)
      : id = int.parse(json['id']),
        video_id = int.parse(json['video_id']),
        user_id = (json['user_id']),
        comment = json['comment'],
        timestamp = DateTime.parse(json['timestamp']),
        username = json['username'],
        likeCount = int.parse(json['likeCount']),
        liked = json['liked'];

  Map toJson() {
    return {
      'id': id,
      'video_id': video_id,
      'user_id': user_id,
      'comment': comment,
      'timestamp': timestamp.toString(),
      'username': username,
      'likeCount': likeCount,
      'liked': liked
    };
  }
}

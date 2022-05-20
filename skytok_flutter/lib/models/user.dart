class User {
  int id;
  String username;
  String? picturePath;
  String? biography;
  bool? userFollowing;

  User(this.id, this.username, this.picturePath, this.biography,
      this.userFollowing);

  User.fromJson(Map json)
      : id = json['id'],
        username = json['username'],
        picturePath = json['picturePath'],
        biography = json['biography'],
        userFollowing = json['userFollowing'];

  Map toJson() {
    return {
      'id': id,
      'username': username,
      'picturePath': picturePath,
      'biography': biography,
      'userFollowing': userFollowing,
    };
  }
}

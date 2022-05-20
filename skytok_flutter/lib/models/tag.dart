class Tag {
  int id;
  String tag;

  Tag(this.id, this.tag);

  Tag.fromJson(Map json)
      : id = int.parse(json['id']),
        tag = json['tag'];

  Map toJson() {
    return {
      'id': id,
      'tag': tag,
    };
  }
}

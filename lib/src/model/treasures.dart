class Treasure {
  final String id;
  final String name;
  final String tagId;
  final String imageUrl;

  Treasure(this.id, this.name, this.tagId, this.imageUrl);

  Treasure.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        tagId = json['tag_id'],
        imageUrl = json['image_url'];

  @override
  String toString() {
    return 'Treasure{id: $id, name: $name, tagId: $tagId, imageUrl: $imageUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Treasure &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              tagId == other.tagId &&
              imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      tagId.hashCode ^
      imageUrl.hashCode;
}

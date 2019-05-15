class Treasure {
  final String id;
  final String name;
  final String imageUrl;

  Treasure(this.id, this.name, this.imageUrl);

  Treasure.fromJson(Map<String, String> json)
      : id = json['id'],
        name = json['name'],
        imageUrl = json['imageUrl'];

  @override
  String toString() {
    return 'Treasure{id: $id, name: $name, imageUrl: $imageUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Treasure &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      imageUrl.hashCode;




}

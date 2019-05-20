import 'package:treasure_nfc/src/model/api_models.dart';
import 'package:treasure_nfc/src/resources/completion.dart';
import 'package:treasure_nfc/src/resources/treasure_provider.dart';

class TestTreasureSource implements TreasuresSource {
  final List<Treasure> treasures = [
    Treasure.fromJson({"id": "red", "tag_id": "rid", "name": "Red"}),
    Treasure.fromJson({"id": "green", "tag_id": "gid", "name": "Green"}),
    Treasure.fromJson({"id": "blue", "tag_id": "bid", "name": "Blue"}),
  ];

  @override
  Future<List<Treasure>> fetchTreasures() {
    return Future.value(treasures);
  }
}

class TestCompletion implements Completion {
  @override
  Future<bool> set(String value) {
    return Future.value(true);
  }
}
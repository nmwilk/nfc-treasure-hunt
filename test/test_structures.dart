import 'package:treasure_nfc/src/model/api_models.dart';
import 'package:treasure_nfc/src/resources/completion.dart';
import 'package:treasure_nfc/src/resources/recorder.dart';
import 'package:treasure_nfc/src/resources/treasure_provider.dart';

class TestRecorder implements Recorder {
  final keys = <String>[];

  @override
  Future clear() {
    keys.clear();
    return Future.value(null);
  }

  @override
  Future<bool> get(String key) async {
    return keys.contains(key);
  }

  @override
  Future set(String key) {
    if (!keys.contains(key)) {
      keys.add(key);
    }
    return Future.value(null);
  }
}

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
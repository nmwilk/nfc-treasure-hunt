import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_nfc/src/resources/recorder.dart';
import 'package:treasure_nfc/src/resources/repo.dart';
import 'package:treasure_nfc/src/resources/treasure_provider.dart';
import 'package:treasure_nfc/src/resources/treasures.dart';

void main() {
  test('get treasure data nothing found', () async {
    final repo = Repo(
      TestTreasureSource([
        Treasure.fromJson({"id": "red", "name": "Red"}),
        Treasure.fromJson({"id": "green", "name": "Green"}),
        Treasure.fromJson({"id": "blue", "name": "Blue"}),
      ]),
      TestRecorder(),
    );

    final treasureRecords = await repo.getRecords();

    expect(treasureRecords, [
      TreasureRecord(Treasure("red", "Red", null), false),
      TreasureRecord(Treasure("green", "Green", null), false),
      TreasureRecord(Treasure("blue", "Blue", null), false),
    ]);
  });

  test('get treasure data 1 found', () async {
    var testRecorder = TestRecorder();
    testRecorder.set("red");

    final repo = Repo(
      TestTreasureSource([
        Treasure.fromJson({"id": "red", "name": "Red"}),
        Treasure.fromJson({"id": "green", "name": "Green"}),
        Treasure.fromJson({"id": "blue", "name": "Blue"}),
      ]),
      testRecorder,
    );

    final treasureRecords = await repo.getRecords();

    expect(treasureRecords, [
      TreasureRecord(Treasure("red", "Red", null), true),
      TreasureRecord(Treasure("green", "Green", null), false),
      TreasureRecord(Treasure("blue", "Blue", null), false),
    ]);
  });

  test('get treasure data all found', () async {
    var testRecorder = TestRecorder();
    testRecorder.set("red");
    testRecorder.set("blue");
    testRecorder.set("green");

    final repo = Repo(
      TestTreasureSource([
        Treasure.fromJson({"id": "red", "name": "Red"}),
        Treasure.fromJson({"id": "green", "name": "Green"}),
        Treasure.fromJson({"id": "blue", "name": "Blue"}),
      ]),
      testRecorder,
    );

    final treasureRecords = await repo.getRecords();

    expect(treasureRecords, [
      TreasureRecord(Treasure("red", "Red", null), true),
      TreasureRecord(Treasure("green", "Green", null), true),
      TreasureRecord(Treasure("blue", "Blue", null), true),
    ]);
  });
}

class TestTreasureSource implements TreasuresSource {
  final List<Treasure> treasures;

  TestTreasureSource(this.treasures);

  @override
  Future<List<Treasure>> fetchTreasures() {
    return Future.value(treasures);
  }
}

class TestRecorder implements Recorder {
  final keys = <String>[];

  @override
  void clear() {
    keys.clear();
  }

  @override
  Future<bool> get(String key) async {
    return Future.value(keys.contains(key));
  }

  @override
  void set(String key) {
    if (!keys.contains(key)) {
      keys.add(key);
    }
  }
}

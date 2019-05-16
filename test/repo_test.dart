import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_nfc/src/model/api_models.dart';
import 'package:treasure_nfc/src/model/app_models.dart';
import 'package:treasure_nfc/src/resources/repo.dart';

import 'test_structures.dart';

void main() {
  test('get treasure data nothing found', () async {
    final repo = Repo(
      TestTreasureSource(),
      TestRecorder(),
    );

    final treasureRecords = await repo.getRecords();

    expect(treasureRecords, [
      TreasureRecord(Treasure("red", "Red", "rid", ''), false),
      TreasureRecord(Treasure("green", "Green", "gid", ''), false),
      TreasureRecord(Treasure("blue", "Blue", "bid", ''), false),
    ]);
  });

  test('get treasure data 1 found', () async {
    final testRecorder = TestRecorder();
    testRecorder.set("red");

    final repo = Repo(
      TestTreasureSource(),
      testRecorder,
    );

    final treasureRecords = await repo.getRecords();

    expect(treasureRecords, [
      TreasureRecord(Treasure("red", "Red", "rid", ''), true),
      TreasureRecord(Treasure("green", "Green", "gid", ''), false),
      TreasureRecord(Treasure("blue", "Blue", "bid", ''), false),
    ]);
  });

  test('get treasure data all found', () async {
    final testRecorder = TestRecorder();
    testRecorder.set("red");
    testRecorder.set("blue");
    testRecorder.set("green");

    final repo = Repo(
      TestTreasureSource(),
      testRecorder,
    );

    final treasureRecords = await repo.getRecords();

    expect(treasureRecords, [
      TreasureRecord(Treasure("red", "Red", "rid", ''), true),
      TreasureRecord(Treasure("green", "Green", "gid", ''), true),
      TreasureRecord(Treasure("blue", "Blue", "bid", ''), true),
    ]);
  });
}

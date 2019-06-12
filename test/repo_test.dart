import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_nfc/src/model/api_models.dart';
import 'package:treasure_nfc/src/model/app_models.dart';
import 'package:treasure_nfc/src/resources/memory_structures.dart';
import 'package:treasure_nfc/src/resources/repo.dart';

import 'test_structures.dart';

void main() {
  test('get treasure data nothing found', () async {
    final repo = Repo(
      TestTreasureSource(),
      InMemoryRecorder(),
      TestCompletion(),
    );

    final treasureRecords = await repo.getRecords();

    expect(treasureRecords, [
      TreasureRecord(Treasure("red", "Red", "rid", ''), false),
      TreasureRecord(Treasure("green", "Green", "gid", ''), false),
      TreasureRecord(Treasure("blue", "Blue", "bid", ''), false),
    ]);
  });

  test('get treasure data 1 found', () async {
    final testRecorder = InMemoryRecorder();
    testRecorder.setFound("rid");

    final repo = Repo(
      TestTreasureSource(),
      testRecorder,
      TestCompletion(),
    );

    final treasureRecords = await repo.getRecords();

    expect(treasureRecords, [
      TreasureRecord(Treasure("red", "Red", "rid", ''), true),
      TreasureRecord(Treasure("green", "Green", "gid", ''), false),
      TreasureRecord(Treasure("blue", "Blue", "bid", ''), false),
    ]);
  });

  test('get treasure data all found', () async {
    final testRecorder = InMemoryRecorder();
    testRecorder.setFound("rid");
    testRecorder.setFound("bid");
    testRecorder.setFound("gid");

    final repo = Repo(
      TestTreasureSource(),
      testRecorder,
      TestCompletion(),
    );

    final treasureRecords = await repo.getRecords();

    expect(treasureRecords, [
      TreasureRecord(Treasure("red", "Red", "rid", ''), true),
      TreasureRecord(Treasure("green", "Green", "gid", ''), true),
      TreasureRecord(Treasure("blue", "Blue", "bid", ''), true),
    ]);
  });
}

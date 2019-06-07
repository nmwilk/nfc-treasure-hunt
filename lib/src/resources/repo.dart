import 'package:treasure_nfc/src/model/api_models.dart';
import 'package:treasure_nfc/src/model/app_models.dart';
import 'package:treasure_nfc/src/resources/recorder.dart';
import 'package:treasure_nfc/src/resources/treasure_provider.dart';

import 'completion.dart';

class Repo {
  final TreasuresSource treasuresSource;
  final Recorder recorder;
  final Completion completion;

  final List<Treasure> cachedTreasures = [];

  Repo(this.treasuresSource, this.recorder, this.completion);

  Future<List<TreasureRecord>> getRecords() async {
    List<Treasure> treasures;

    if (cachedTreasures.isEmpty) {
      treasures = await treasuresSource.fetchTreasures();
      cachedTreasures.addAll(treasures);
    } else {
      treasures = cachedTreasures;
    }

    final treasureRecords = <TreasureRecord>[];
    for (Treasure treasure in treasures) {
      final found = await recorder.getFound(treasure.tagId);
      print("${treasure.tagId} found? $found");
      treasureRecords.add(TreasureRecord(treasure, found));
    }

    return treasureRecords;
  }

  Future recordFound(String id) async {
    await recorder.setFound(id);
  }

  Future clearFound() async {
    await recorder.clearFound();
  }

  Future<bool> markNameSubmitted(String name) async {
    final posted = await completion.set(name);
    if (posted) {
      print('Marked name posted');
      await recorder.setPostedName();
    }
    return posted;
  }

  Future<bool> postedName() async {
    return await recorder.hasPostedName();
  }
}

import 'package:treasure_nfc/src/model/app_models.dart';
import 'package:treasure_nfc/src/resources/recorder.dart';
import 'package:treasure_nfc/src/resources/treasure_provider.dart';

import 'completion.dart';

class Repo {
  final TreasuresSource treasuresSource;
  final Recorder recorder;
  final Completion completion;

  Repo(this.treasuresSource, this.recorder, this.completion);

  Future<List<TreasureRecord>> getRecords() async {
    final treasures = await treasuresSource.fetchTreasures();

    final treasureRecords = <TreasureRecord>[];
    await treasures.forEach((treasure) async {
      final found = await recorder.getFound(treasure.id);
      treasureRecords.add(TreasureRecord(treasure, found));
    });

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

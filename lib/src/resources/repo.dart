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
      final found = await recorder.get(treasure.id);
      treasureRecords.add(TreasureRecord(treasure, found));
    });

    return treasureRecords;
  }

  Future recordFound(String id) async {
    await recorder.set(id);
  }

  Future clearFound() async {
    await recorder.clear();
  }

  Future<bool> markNameSubmitted(String name) async {
    final posted = await completion.set(name);
    if (posted) {
      print('Marked name posted');
      await recorder.set('postedname');
    }
    return posted;
  }

  Future<bool> postedName() async {
    return await recorder.get('postedname');
  }
}

import 'package:rxdart/rxdart.dart';
import 'package:treasure_nfc/src/model/app_models.dart';
import 'package:treasure_nfc/src/resources/api.dart';
import 'package:treasure_nfc/src/resources/recorder.dart';
import 'package:treasure_nfc/src/resources/treasure_provider.dart';

class Repo {
  final TreasuresSource treasuresSource;
  final Recorder recorder;
  final ApiCompletion completion = ApiCompletion();

  final _name = BehaviorSubject<String>();

  Repo(this.treasuresSource, this.recorder);

  Future<List<TreasureRecord>> getRecords() async {
    final treasures = await treasuresSource.fetchTreasures();

    final treasureRecords = <TreasureRecord>[];
    await treasures.forEach((treasure) async { // ignore: await_only_futures
      final found = await recorder.get(treasure.id);
      treasureRecords.add(TreasureRecord(treasure, found));
      return treasureRecords;
    });

    return treasureRecords;
  }

  void recordFound(String id) {
    recorder.set(id);
  }

  void clearFound() {
    recorder.clear();
  }

  Future<bool> markCompleted() {
    return completion.set(_name.value);
  }

  dispose() {
    _name.close();
  }
}
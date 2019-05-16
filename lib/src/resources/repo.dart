import 'package:rxdart/rxdart.dart';
import 'package:treasure_nfc/src/resources/api.dart';
import 'package:treasure_nfc/src/resources/recorder.dart';
import 'package:treasure_nfc/src/resources/treasure_provider.dart';
import 'package:treasure_nfc/src/model/treasures.dart';

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

class TreasureRecord {
  final Treasure treasure;
  final bool found;

  TreasureRecord(this.treasure, this.found);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TreasureRecord &&
              runtimeType == other.runtimeType &&
              treasure == other.treasure &&
              found == other.found;

  @override
  int get hashCode =>
      treasure.hashCode ^
      found.hashCode;

  @override
  String toString() {
    return 'TreasureRecord{treasure: $treasure, found: $found}';
  }
}

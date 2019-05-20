import 'package:treasure_nfc/src/resources/recorder.dart';

class InMemoryRecorder implements Recorder {
  final keys = <String>[];
  var postedName = false;

  @override
  Future clearFound() {
    keys.clear();
    return Future.value(null);
  }

  @override
  Future<bool> getFound(String key) async {
    return keys.contains(key);
  }

  @override
  Future setFound(String key) async {
    if (!keys.contains(key)) {
      keys.add(key);
    }
    return Future.value(null);
  }

  @override
  Future<bool> hasPostedName() {
    return Future.value(postedName);
  }

  @override
  Future setPostedName() {
    postedName = true;
    return Future.value(null);
  }
}
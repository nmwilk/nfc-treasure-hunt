import 'package:treasure_nfc/src/resources/recorder.dart';

class InMemoryRecorder implements Recorder {
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
  Future set(String key) async {
    if (!keys.contains(key)) {
      keys.add(key);
    }
    return null;
  }
}
import 'package:treasure_nfc/src/resources/recorder.dart';

class InMemoryRecorder implements Recorder {
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treasure_nfc/src/resources/recorder.dart';

class PrefsRecorder implements Recorder {
  @override
  Future clear() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  @override
  Future<bool> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    var value = prefs.getBool(key);
    return value != null;
  }

  @override
  Future set(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, true);
  }
}
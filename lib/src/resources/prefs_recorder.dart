import 'package:shared_preferences/shared_preferences.dart';
import 'package:treasure_nfc/src/resources/recorder.dart';

class PrefsRecorder implements Recorder {
  static final _postedNameKey = 'postedname';

  @override
  Future clearFound() async {
    final prefs = await SharedPreferences.getInstance();
    final postedName = prefs.getBool(_postedNameKey);
    await prefs.clear();
    return prefs.setBool(_postedNameKey, postedName);
  }

  @override
  Future<bool> getFound(String key) async {
    final prefs = await SharedPreferences.getInstance();
    var value = prefs.getBool(key);
    return value != null;
  }

  @override
  Future setFound(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, true);
  }

  @override
  Future<bool> hasPostedName() async {
    final prefs = await SharedPreferences.getInstance();
    var value = prefs.getBool(_postedNameKey);
    return value != null;
  }

  @override
  Future setPostedName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_postedNameKey, true);
  }
}
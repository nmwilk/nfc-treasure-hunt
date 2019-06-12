import 'package:treasure_nfc/src/bloc.dart';
import 'package:treasure_nfc/src/nfc/nfc_source.dart';

class FakeNfc implements NfcSource {
  @override
  Future<void> startNfc(Bloc bloc) {
    return Future.value(null);
  }

  @override
  Future<void> stopNfc(Bloc bloc) {
    return Future.value(null);
  }
}
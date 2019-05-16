import 'package:http/http.dart';
import 'package:treasure_nfc/src/model/api_models.dart';
import 'package:treasure_nfc/src/resources/treasure_provider.dart';

class FakeTreasuresSource implements TreasuresSource {
  final client = Client();

  @override
  Future<List<Treasure>> fetchTreasures() async {
    return Future.value([
      Treasure("0x046fa152bb5c80", "Apple", "0x046fa152bb5c80",
          "https://api.adorable.io/avatars/400/apple.png"),
      Treasure("0x0498ab12314c80", "Banana", "0x0498ab12314c80",
          "https://api.adorable.io/avatars/400/asfthuikpple.png"),
    ]);
  }
}
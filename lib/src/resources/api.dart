import 'package:treasure_nfc/src/resources/treasure_provider.dart';
import 'package:treasure_nfc/src/resources/treasures.dart';
import 'package:http/http.dart' show Client;

class ApiTreasuresSource implements TreasuresSource {
  final client = Client();

  @override
  Future<List<Treasure>> fetchTreasures() async {
    return Future.value([
      Treasure("1", "Apple", "https://api.adorable.io/avatars/400/apple.png"),
      Treasure("2", "Banana", "https://api.adorable.io/avatars/400/asfthuikpple.png"),
      Treasure("3", "Carrot", "https://api.adorable.io/avatars/400/fshgsrfg.png"),
      Treasure("4", "Dried Apricot", "https://api.adorable.io/avatars/400/fpggi.png"),
      Treasure("5", "Earth", "https://api.adorable.io/avatars/400/fig9iownf.png"),
      Treasure("6", "Fried Chicken", "https://api.adorable.io/avatars/400/fgighsfs.png"),
      Treasure("7", "Garlic", "https://api.adorable.io/avatars/400/garlic.png"),
      Treasure("8", "Hemp", "https://api.adorable.io/avatars/400/hemp.png"),
    ]);
  }
}


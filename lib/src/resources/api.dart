import 'dart:convert';

import 'package:http/http.dart' show Client;
import 'package:treasure_nfc/src/resources/treasure_provider.dart';
import 'package:treasure_nfc/src/model/treasures.dart';

class ApiTreasuresSource implements TreasuresSource {
  final client = Client();

  @override
  Future<List<Treasure>> fetchTreasures() async {
    final response = await client.get(
        'https://615xps11jj.execute-api.eu-west-2.amazonaws.com/aarrr/treasures');
    final treasuresMap = json.decode(response.body)['treasures'];
    final treasures = <Treasure>[];

    treasuresMap.forEach((item) {
      treasures.add(Treasure.fromJson(item));
    });

    return treasures;
  }
}

class ApiCompletion {
  final client = Client();

  Future<bool> set(String value) async {
    final result = await client.put(
        'https://615xps11jj.execute-api.eu-west-2.amazonaws.com/aarrr/names',
        body: {"name": "$value"},
        headers: {"Content-Type": "application/json"});

    return result.statusCode / 100 == 2;
  }
}

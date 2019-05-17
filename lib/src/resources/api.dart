import 'dart:convert';

import 'package:http/http.dart' show Client;
import 'package:treasure_nfc/src/model/api_models.dart';
import 'package:treasure_nfc/src/resources/completion.dart';
import 'package:treasure_nfc/src/resources/treasure_provider.dart';

class ApiTreasuresSource implements TreasuresSource {
  final client = Client();

  @override
  Future<List<Treasure>> fetchTreasures() async {
    print('fetching treasures');
    final response = await client.get(
        'https://615xps11jj.execute-api.eu-west-2.amazonaws.com/aarrr/treasures');
    final treasuresMap = json.decode(response.body)['treasures'];
    final treasures = <Treasure>[];

    treasuresMap.forEach((item) {
      treasures.add(Treasure.fromJson(item));
    });

    print('- ${response.statusCode}');

    return treasures;
  }
}

class ApiCompletion implements Completion {
  final client = Client();

  @override
  Future<bool> set(String value) async {
    print('posting name');
    final response = await client.put(
        'https://615xps11jj.execute-api.eu-west-2.amazonaws.com/aarrr/names',
        body: json.encode({"name": "$value"}),
        headers: {"Content-Type": "application/json"});

    print('- ${response.statusCode}');
    return response.statusCode / 100 == 2;
  }
}


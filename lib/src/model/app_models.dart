import 'package:treasure_nfc/src/model/api_models.dart';

class TreasureRecord {
  final Treasure treasure;
  final bool found;

  TreasureRecord(this.treasure, this.found);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TreasureRecord &&
              runtimeType == other.runtimeType &&
              treasure == other.treasure &&
              found == other.found;

  @override
  int get hashCode =>
      treasure.hashCode ^
      found.hashCode;

  @override
  String toString() {
    return 'TreasureRecord{treasure: $treasure, found: $found}';
  }
}

class ScanStatus {
  final String id;
  final String message;
  final bool scanning;
  final bool error;

  ScanStatus(this.id, this.message, this.scanning, this.error);

  bool operator ==(o) =>
      o is ScanStatus &&
          o.id == id &&
          o.message == message &&
          o.error == error &&
          o.scanning == scanning;

  @override
  String toString() {
    return 'ScanStatus{id: $id, message: $message, scanning: $scanning, error: $error}';
  }
}


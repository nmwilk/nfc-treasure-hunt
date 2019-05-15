import 'dart:async';

import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treasure_nfc/src/resources/api.dart';
import 'package:treasure_nfc/src/resources/memory_structures.dart';
import 'package:treasure_nfc/src/resources/repo.dart';

class Bloc {
  final Repo _repo = Repo(
      ApiTreasuresSource(),
      InMemoryRecorder()
  );

  final _nfcData = PublishSubject<NfcData>();
  final _scanStatusOutput = BehaviorSubject<ScanStatus>();

  final _treasures = PublishSubject<List<TreasureRecord>>();

  Stream<List<TreasureRecord>> get treasures => _treasures.stream;

  Function(NfcData) get changeNfcData => _nfcData.sink.add;

  Stream<ScanStatus> get scanStatus => _scanStatusOutput.stream;

  StreamTransformer<NfcData, ScanStatus> nfcDataMapper() {
    return StreamTransformer<NfcData, ScanStatus>.fromHandlers(
        handleData: (nfcData, sink) {
      var scanStatus;
      if (nfcData.status == NFCStatus.reading ||
          nfcData.status == NFCStatus.none) {
        scanStatus = ScanStatus(nfcData.id, nfcData.content, true);
      } else {
        scanStatus = ScanStatus('', 'Error', false);
      }

      sink.add(scanStatus);
    });
  }

  refreshTreasures() async {
    final records = await _repo.getRecords();
    _treasures.sink.add(records);
  }

  recordFound(String id) {
    _repo.recordFound(id);
    refreshTreasures();
  }

  clearFound() {
    _repo.clearFound();
    refreshTreasures();
  }

  Bloc() {
    _nfcData.stream.transform(nfcDataMapper()).pipe(_scanStatusOutput);
  }

  dispose() {
    _treasures.close();
    _nfcData.close();
    _scanStatusOutput.close();
  }
}

class ScanStatus {
  final String id;
  final String message;
  final bool scanning;

  ScanStatus(this.id, this.message, this.scanning);

  bool operator == (o) => o is ScanStatus && o.id == id && o.message == message && o.scanning == scanning;

  @override
  String toString() {
    return 'id: $id, message: $message, scanning: $scanning';
  }
}

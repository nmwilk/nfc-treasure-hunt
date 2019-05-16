import 'dart:async';

import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treasure_nfc/src/model/app_models.dart';
import 'package:treasure_nfc/src/resources/api.dart';
import 'package:treasure_nfc/src/resources/memory_structures.dart';
import 'package:treasure_nfc/src/resources/repo.dart';

class Bloc {
  final Repo _repo;

  final _treasures = PublishSubject<List<TreasureRecord>>();
  final _nfcData = PublishSubject<NfcData>();
  final _scanStatusOutput = BehaviorSubject<ScanStatus>();
  final _namePrompt = PublishSubject<bool>();

  Stream<bool> get showCompleteNamePrompt => _namePrompt.stream.distinct();
  Stream<ScanStatus> get scanStatus => _scanStatusOutput.stream;
  Stream<List<TreasureRecord>> get treasures => _treasures.stream;
  StreamTransformer<NfcData, ScanStatus> nfcDataMapper() {
    return StreamTransformer<NfcData, ScanStatus>.fromHandlers(
        handleData: (nfcData, sink) {
      var scanStatus;
      if (nfcData.status == NFCStatus.reading ||
          nfcData.status == NFCStatus.none) {
        scanStatus = ScanStatus(nfcData.id, nfcData.content, true, false);
      } else if (nfcData.error != null && nfcData.error != ''){
        scanStatus = ScanStatus('', 'Error', false, true);
      } else {
        scanStatus = ScanStatus('', '', false, false);
      }

      sink.add(scanStatus);
    });
  }

  Function(NfcData) get changeNfcData => _nfcData.sink.add;

  refreshTreasures() async {
    final records = await _repo.getRecords();
    _treasures.sink.add(records);
    final firstTreasureNotFoundYet =
        records.firstWhere((record) => !record.found, orElse: () => null);
    _namePrompt.sink.add(firstTreasureNotFoundYet == null);
  }

  recordFound(String id) {
    _repo.recordFound(id);
    refreshTreasures();
  }

  clearFound() {
    _repo.clearFound();
    refreshTreasures();
  }

  Bloc(this._repo);

  Bloc.prod() : _repo = Repo(ApiTreasuresSource(), InMemoryRecorder()) {
    _nfcData.stream.transform(nfcDataMapper()).pipe(_scanStatusOutput);
  }

  dispose() {
    _treasures.close();
    _nfcData.close();
    _scanStatusOutput.close();
    _namePrompt.close();
  }
}

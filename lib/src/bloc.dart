import 'dart:async';

import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treasure_nfc/src/mixins/validation_mixin.dart';
import 'package:treasure_nfc/src/model/app_models.dart';
import 'package:treasure_nfc/src/nfc/nfc_reader.dart';
import 'package:treasure_nfc/src/resources/api.dart';
import 'package:treasure_nfc/src/resources/fake_api.dart';
import 'package:treasure_nfc/src/resources/memory_structures.dart';
import 'package:treasure_nfc/src/resources/repo.dart';

class Bloc extends ValidationMixin {
  final Repo _repo;

  final nfcReader = NfcReader();

  final _treasures = PublishSubject<List<TreasureRecord>>();
  final _nfcData = PublishSubject<NfcData>();
  final _scanStatusOutput = BehaviorSubject<ScanStatus>();
  final _namePrompt = PublishSubject<bool>();
  final _name = BehaviorSubject<String>();

  Stream<String> get name => _name.stream.transform(validateName);

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
      } else if (nfcData.error != null && nfcData.error != '') {
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

    final postedName = await _repo.postedName();
    if (!postedName) {
      _namePrompt.sink.add(firstTreasureNotFoundYet == null);
    }
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

  Bloc.local() : _repo = Repo(FakeTreasuresSource(), InMemoryRecorder()) {
    _nfcData.stream.transform(nfcDataMapper()).pipe(_scanStatusOutput);
  }

  dispose() {
    _treasures.close();
    _nfcData.close();
    _scanStatusOutput.close();
    _namePrompt.close();
    _name.close();
  }

  Future<String> markNameSubmitted() async {
    _repo.markNameSubmitted(_name.value);
    return Future.value(_name.value);
  }

  Future<bool> isNameSubmitted() => _repo.postedName();

  void changeName(String value) {
    _name.sink.add(value);
  }

  Future<void> startScanning() {
    return nfcReader.startNfc(this);
  }

  Future<void> stopNfc() {
    return nfcReader.stopNfc(this);
  }
}

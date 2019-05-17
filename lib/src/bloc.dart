import 'dart:async';

import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treasure_nfc/src/mixins/validation_mixin.dart';
import 'package:treasure_nfc/src/model/app_models.dart';
import 'package:treasure_nfc/src/nfc/nfc_reader.dart';
import 'package:treasure_nfc/src/resources/api.dart';
import 'package:treasure_nfc/src/resources/fake_api.dart';
import 'package:treasure_nfc/src/resources/memory_structures.dart';
import 'package:treasure_nfc/src/resources/prefs_recorder.dart';
import 'package:treasure_nfc/src/resources/repo.dart';

class Bloc extends ValidationMixin {
  final Repo _repo;

  final nfcReader = NfcReader();

  final _treasures = BehaviorSubject<List<TreasureRecord>>();
  final _nfcData = PublishSubject<NfcData>();
  final _scanStatusOutput = BehaviorSubject<ScanStatus>();
  final _namePrompt = PublishSubject<bool>();
  final _name = BehaviorSubject<String>();

  Stream<String> get name => _name.stream.transform(validateName);

  var showCompleteNamePrompt;

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

      print('${scanStatus.toString()}');
      sink.add(scanStatus);
    });
  }

  Function(NfcData) get changeNfcData => _nfcData.sink.add;

  refreshTreasures() async {
    print('refreshTreasures');
    final records = await _repo.getRecords();
    _treasures.sink.add(records);

    var gotAllTreasures = records.isNotEmpty;
    records.forEach((treasureRecord) {
      if (!treasureRecord.found) {
        gotAllTreasures = false;
      }
    });

    print('gotAllTreasures: $gotAllTreasures');

    final postedName = await _repo.postedName();
    _namePrompt.sink.add(records.isNotEmpty && gotAllTreasures && !postedName);

    if (gotAllTreasures) {
      await stopScanning();
    }
  }

  recordFound(String id) async {
    print('recordFound $id');
    await _repo.recordFound(id);
    refreshTreasures();
  }

  clearFound() async {
    print('clearFound');
    await _repo.clearFound();
    refreshTreasures();
  }

  Bloc(this._repo) {
    print('created bloc');
    showCompleteNamePrompt = _namePrompt.stream.distinct();
    _nfcData.stream.transform(nfcDataMapper()).pipe(_scanStatusOutput);
    refreshTreasures();
  }

  Bloc.prod() : this(Repo(ApiTreasuresSource(), PrefsRecorder(), ApiCompletion()));

  Bloc.local() : this(Repo(FakeTreasuresSource(), InMemoryRecorder(), ApiCompletion()));

  dispose() {
    _treasures.close();
    _nfcData.close();
    _scanStatusOutput.close();
    _namePrompt.close();
    _name.close();
  }

  Future<String> markNameSubmitted() async {
    await _repo.markNameSubmitted(_name.value);
    return _name.value;
  }

  Future<bool> isNameSubmitted() => _repo.postedName();

  void changeName(String value) {
    _name.sink.add(value);
  }

  Future<void> startScanning() {
    print('startScanning');
    return nfcReader.startNfc(this);
  }

  Future<void> stopScanning() {
    print('startScanning');
    return nfcReader.stopNfc(this);
  }
}

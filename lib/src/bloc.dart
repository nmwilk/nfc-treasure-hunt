import 'dart:async';

import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treasure_nfc/src/mixins/validation_mixin.dart';
import 'package:treasure_nfc/src/model/app_models.dart';
import 'package:treasure_nfc/src/nfc/nfc_reader.dart';
import 'package:treasure_nfc/src/nfc/nfc_source.dart';
import 'package:treasure_nfc/src/resources/api.dart';
import 'package:treasure_nfc/src/resources/fake_api.dart';
import 'package:treasure_nfc/src/resources/prefs_recorder.dart';
import 'package:treasure_nfc/src/resources/repo.dart';

class Bloc extends ValidationMixin {
  final Repo _repo;

  final NfcSource _nfcReader;

  Stream<List<TreasureRecord>> get treasures => _treasures.stream;
  final _treasures = BehaviorSubject<List<TreasureRecord>>();

  final _nfcData = PublishSubject<NfcData>();
  var scanStatus;
  final _scanStatusOutput = BehaviorSubject<ScanStatus>();

  final _endPrompt = PublishSubject<bool>();
  final _name = BehaviorSubject<String>();

  Stream<String> get name => _name.stream.transform(validateName);

  var showCompletePrompt;

  StreamTransformer<NfcData, ScanStatus> nfcDataMapper() {
    return StreamTransformer<NfcData, ScanStatus>.fromHandlers(
        handleData: (nfcData, sink) {
      var scanStatus;
      if (nfcData.status == NFCStatus.reading ||
          nfcData.status == NFCStatus.none) {
        scanStatus = ScanStatus(nfcData.id, nfcData.content, true, false);
      } else if (nfcData.status == NFCStatus.error ||
          (nfcData.error != null && nfcData.error != '')) {
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

    print('- got ${records.length} treasures');
    _treasures.sink.add(records);

    var gotAllTreasures = records.isNotEmpty;
    records.forEach((treasureRecord) {
      if (!treasureRecord.found) {
        gotAllTreasures = false;
      }
    });

    print('gotAllTreasures: $gotAllTreasures');

    final postedName = await _repo.postedName();
    if (records.isNotEmpty && gotAllTreasures) {
      _endPrompt.sink.add(!postedName);
    }
  }

  recordFound(String id) async {
    print('recordFound $id');
    await _repo.recordFound(id);
    refreshTreasures();
  }

  restart() async {
    print('restart');
    await _repo.clearFound();
    refreshTreasures();
  }

  Bloc(this._repo, this._nfcReader) {
    print('created bloc');
    showCompletePrompt = _endPrompt.stream;
    scanStatus = _scanStatusOutput.stream.distinct();
    _nfcData.stream.transform(nfcDataMapper()).pipe(_scanStatusOutput);
    refreshTreasures();
    startScanning();
  }

  Bloc.prod() : this(Repo(ApiTreasuresSource(), PrefsRecorder(), ApiCompletion()), NfcReader());

  Bloc.local() : this(Repo(FakeTreasuresSource(), PrefsRecorder(), ApiCompletion()), NfcReader());

  dispose() {
    _stopScanning();
    _treasures.close();
    _nfcData.close();
    _scanStatusOutput.close();
    _endPrompt.close();
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
    return _nfcReader.startNfc(this);
  }

  Future<void> _stopScanning() {
    print('stopScanning');
    return _nfcReader.stopNfc(this);
  }
}

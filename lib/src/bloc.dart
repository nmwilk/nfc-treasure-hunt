import 'dart:async';

import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:rxdart/rxdart.dart';

class Bloc {
  final _nfcData = PublishSubject<NfcData>();
  final _scanStatusOutput = BehaviorSubject<ScanStatus>();

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

  Bloc() {
    _nfcData.stream.transform(nfcDataMapper()).pipe(_scanStatusOutput);
  }

  dispose() {
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

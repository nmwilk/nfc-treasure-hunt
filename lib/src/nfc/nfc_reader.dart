import 'package:flutter/services.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:treasure_nfc/src/bloc.dart';

class NfcReader {
  var scanning = false;

  Future<void> startNfc(Bloc bloc) async {
    if (!scanning) {
      scanning = true;

      final nfcData = NfcData();
      nfcData.status = NFCStatus.reading;
      bloc.changeNfcData(nfcData);

      print('NFC: Scan started');

      FlutterNfcReader.read.listen((response) async {
        print('NFC: Scan read NFC tag ${response.id} [${response.content}]');
        bloc.changeNfcData(response);
        await bloc.recordFound(response.id);
      }, onError: (error) {
        print('NFC: Scan error $error');
        bloc.changeNfcData(NfcData(id: '', content: '', error: 'No hardware'));
        scanning = false;
      });
    }
  }

  Future<void> stopNfc(Bloc bloc) async {
    if (scanning) {
      scanning = false;
      NfcData response;

      try {
        print('NFC: Stop scan');
        response = await FlutterNfcReader.stop;
        bloc.changeNfcData(response);
      } on PlatformException {
        print('NFC: Stop scan exception');
        response = NfcData(
          id: '',
          content: '',
          error: 'NFC scan stop exception',
          statusMapper: '',
        );
        response.status = NFCStatus.error;
        bloc.changeNfcData(response);
      }
    }
  }
}

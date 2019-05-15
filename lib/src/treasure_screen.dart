import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:treasure_nfc/src/bloc.dart';
import 'package:treasure_nfc/src/bloc_provider.dart';

class TreasureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of(context);
    startNFC(bloc);

    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: StreamBuilder(
                stream: bloc.scanStatus,
                builder: (context, AsyncSnapshot<ScanStatus> snapshot) {
                  return snapshot.hasData && snapshot.data.scanning
                      ? RefreshProgressIndicator(
                      backgroundColor: Colors.deepOrange)
                      : Icon(Icons.error);
                },
              ),
            ),
            Center(
              child: Text(
                "Treasure Hunt",
                textAlign: TextAlign.center,
                style: Theme
                    .of(context)
                    .textTheme
                    .headline,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: RaisedButton(
            onPressed: () {
              bloc.changeNfcData(
                  NfcData(id: '', content: '', error: 'No hardware'));
            },
            child: Text('Click Me'),
      ),
    ),);
  }

  Future<void> startNFC(Bloc bloc) async {
    final nfcData = NfcData();
    nfcData.status = NFCStatus.reading;
    bloc.changeNfcData(nfcData);

    print('NFC: Scan started');

    print('NFC: Scan readed NFC tag');
    FlutterNfcReader.read.listen((response) {
      bloc.changeNfcData(response);
    }, onError: (error) {
      bloc.changeNfcData(NfcData(id: '', content: '', error: 'No hardware'));
    });
  }
}

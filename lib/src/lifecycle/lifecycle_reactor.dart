import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';

class AppLifecycleReactor extends StatefulWidget {
  const AppLifecycleReactor({Key key}) : super(key: key);

  @override
  _AppLifecycleReactorState createState() => _AppLifecycleReactorState();
}

class _AppLifecycleReactorState extends State<AppLifecycleReactor>
    with WidgetsBindingObserver {
  NfcData _nfcData;

  @override
  void initState() {
    print('initState');
    super.initState();
    startNFC();
  }

  @override
  void dispose() {
    print('dispose');
    stopNFC();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppLifecycleReactor oldWidget) {
    print('didUpdateWidget');
    startNFC();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return new SafeArea(
      top: true,
      bottom: true,
      child: new Center(
        child: ListView(
          children: <Widget>[
            new SizedBox(
              height: 10.0,
            ),
            new Text(
              '- NFC Status -\n',
              textAlign: TextAlign.center,
            ),
            new Text(
              _nfcData != null ? '${_nfcData.status}' : '',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.0),
            new Text(
              (_nfcData != null && _nfcData.id != null)
                  ? 'Identifier: ${_nfcData.id}'
                  : '',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.0),
            new Text(
              _nfcData != null && _nfcData.content != null
                  ? 'Content: ${_nfcData.content}'
                  : '',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.0),
            new Text(
              _nfcData != null && _nfcData.error != null
                  ? 'Error: ${_nfcData.error}'
                  : '',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> startNFC() async {
    setState(() {
      _nfcData = NfcData();
      _nfcData.status = NFCStatus.reading;
    });

    print('NFC: Scan started');

    print('NFC: Scan readed NFC tag');
    FlutterNfcReader.read.listen((response) {
      setState(() {
        _nfcData = response;
      });
    });
  }

  Future<void> stopNFC() async {
    NfcData response;

    try {
      print('NFC: Stop scan by user');
      response = await FlutterNfcReader.stop;
    } on PlatformException {
      print('NFC: Stop scan exception');
      response = NfcData(
        id: '',
        content: '',
        error: 'NFC scan stop exception',
        statusMapper: '',
      );
      response.status = NFCStatus.error;
    }

    setState(() {
      _nfcData = response;
    });
  }
}

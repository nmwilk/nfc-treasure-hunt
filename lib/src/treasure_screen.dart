import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:treasure_nfc/src/bloc.dart';
import 'package:treasure_nfc/src/bloc_provider.dart';
import 'package:treasure_nfc/src/model/app_models.dart';
import 'package:treasure_nfc/src/widget/grid.dart';
import 'package:treasure_nfc/src/widget/title_bar.dart';

class TreasureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of(context);

    bloc.refreshTreasures();

    return Scaffold(
      appBar: AppBar(
        title: TitleBar(bloc: bloc),
      ),
      backgroundColor: Colors.amber.withOpacity(0.5),
      body: Stack(
        children: <Widget>[
          buildTreasuresList(bloc),
          buildCompletion(bloc),
        ],
      ),
    );
  }

  Widget buildTreasuresList(Bloc bloc) {
    return StreamBuilder(
      stream: bloc.treasures,
      builder: (context, AsyncSnapshot<List<TreasureRecord>> snapshot) {
        if (snapshot.hasData) {
          return GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              var treasureRecord = snapshot.data[index];
              return GestureDetector(
                onTap: () {
                  if (treasureRecord.found) {
                    bloc.clearFound();
                  } else {
                    bloc.recordFound(treasureRecord.treasure.id);
                  }
                },
                child:
                    GridCell(context: context, treasureRecord: treasureRecord),
              );
            },
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget buildCompletion(Bloc bloc) {
    return StreamBuilder(
      stream: bloc.showCompleteNamePrompt,
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData && snapshot.data) {
          _stopNFC(bloc);
          return Center(child: Text('Complete'));
        }

        if (snapshot.hasData && !snapshot.data) {
          _startNFC(bloc);
        }
        return Container();
      },
    );
  }

  Future<void> _startNFC(Bloc bloc) async {
    final nfcData = NfcData();
    nfcData.status = NFCStatus.reading;
    bloc.changeNfcData(nfcData);

    print('NFC: Scan started');

    FlutterNfcReader.read.listen((response) {
      print('NFC: Scan read NFC tag');
      bloc.changeNfcData(response);
    }, onError: (error) {
      print('NFC: Scan error $error');
      bloc.changeNfcData(NfcData(id: '', content: '', error: 'No hardware'));
    });
  }

  Future<void> _stopNFC(Bloc bloc) async {
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

import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:treasure_nfc/src/bloc.dart';
import 'package:treasure_nfc/src/bloc_provider.dart';
import 'package:treasure_nfc/src/model/app_models.dart';
import 'package:treasure_nfc/src/resources/repo.dart';
import 'package:treasure_nfc/src/widget/grid.dart';
import 'package:treasure_nfc/src/widget/title_bar.dart';

class TreasureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of(context);

    bloc.refreshTreasures();

    startNFC(bloc);

    return Scaffold(
      appBar: AppBar(
        title: TitleBar(bloc: bloc),
      ),
      body: Stack(
        children: <Widget>[
          buildTreasuresList(bloc),
          buildCompletion(bloc),
        ],
      ),
    );
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
                child: new GridCell(context: context, treasureRecord: treasureRecord),
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
          return Center(
            child: Text('Complete'),
          );
        }
        return Container();
      },
    );
  }
}

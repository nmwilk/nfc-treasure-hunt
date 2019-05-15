import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:treasure_nfc/src/bloc.dart';
import 'package:treasure_nfc/src/bloc_provider.dart';
import 'package:treasure_nfc/src/resources/repo.dart';

class TreasureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of(context);

    bloc.refreshTreasures();

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
                style: Theme.of(context).textTheme.headline,
              ),
            ),
          ],
        ),
      ),
      body: buildTreasuresList(bloc),
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
                child: buildCell(context, treasureRecord),
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

  Stack buildCell(BuildContext context, TreasureRecord treasureRecord) {
    return Stack(
      children: <Widget>[
        Image.network(treasureRecord.treasure.imageUrl),
        Container(
          color: treasureRecord.found ? Colors.transparent : Color(0x90000000),
          child: Center(
            child: SizedBox(
              width: 100.0,
              height: 100.0,
              child: statusIcon(treasureRecord.found),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            child: Text(
                treasureRecord.treasure.name,
                    style: Theme.of(context).textTheme.title,
            ),
            margin: EdgeInsets.only(bottom: 10.0),
          ),
        )
      ],
    );
  }

  Widget statusIcon(bool found) {
    return AnimatedCrossFade(
      firstChild: SizedBox(
        width: 100.0,
        height: 100.0,
        child: Image.asset('images/lock.png'),
      ),
      secondChild: SizedBox(
        width: 100.0,
        height: 100.0,
        child: Image.asset('images/tick.png'),
      ),
      crossFadeState:
          found ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: Duration(milliseconds: 150),
    );
  }
}

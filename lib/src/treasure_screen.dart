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
              return GridCell(context: context, treasureRecord: treasureRecord);
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
        var completed = snapshot.data;
        if (snapshot.hasData && completed) {
          _stopNFC(bloc);

          WidgetsBinding.instance
              .addPostFrameCallback((_) => handleCompleted(context, bloc));
        }

        if (snapshot.hasData && !completed) {
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
      print('NFC: Scan read NFC tag ${response.id} [${response.content}]');
      bloc.changeNfcData(response);
      bloc.recordFound(response.id);
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

  handleCompleted(BuildContext context, Bloc bloc) async {
    final alreadyPosted = await bloc.isNameSubmitted();
    if (!alreadyPosted) {
      return _asyncNameDialog(context, bloc);
    }

    return Future.value("");
  }

  Future<String> _asyncNameDialog(BuildContext context, Bloc bloc) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).backgroundColor,
          title: Column(
            children: <Widget>[
              Text(
                'Well done!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(height: 10.0),
              Text(
                'Enter your name for a chance to win',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Row(
            children: <Widget>[
              Expanded(
                  child: StreamBuilder<String>(
                      stream: bloc.name,
                      builder: (context, snapshot) {
                        return TextField(
                          autofocus: true,
                          keyboardType: TextInputType.text,
                          style: Theme.of(context).textTheme.button,
                          decoration: InputDecoration(
                              labelText: 'Name',
                              hintText: '3 characters or more',
                              errorText: snapshot.error != null
                                  ? snapshot.error
                                  : null),
                          onChanged: (value) {
                            bloc.changeName(value);
                          },
                        );
                      }))
            ],
          ),
          actions: <Widget>[
            StreamBuilder<String>(
                stream: bloc.name,
                builder: (context, snapshot) {
                  return FlatButton(
                    child: Text(
                      'Submit',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    disabledTextColor: Colors.deepOrange,
                    onPressed: snapshot.hasData &&
                            snapshot.data.trim().length >= 3 &&
                            snapshot.error == null
                        ? () async {
                            await bloc.markNameSubmitted();
                            Navigator.of(context).pop();
                          }
                        : null,
                  );
                }),
          ],
        );
      },
    );
  }
}

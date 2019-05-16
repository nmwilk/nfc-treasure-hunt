import 'package:flutter/material.dart';
import 'package:treasure_nfc/src/bloc.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({
    Key key,
    @required this.bloc,
  }) : super(key: key);

  final Bloc bloc;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
    );
  }
}

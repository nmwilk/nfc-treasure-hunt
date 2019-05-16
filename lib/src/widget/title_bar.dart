import 'package:flutter/material.dart';
import 'package:treasure_nfc/src/bloc.dart';
import 'package:treasure_nfc/src/model/app_models.dart';

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
              return buildIcon(snapshot);
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

  Widget buildIcon(AsyncSnapshot<ScanStatus> snapshot) {
    if (!snapshot.hasData) {
      return refreshIndicator();
    } else if (snapshot.data.error) {
      return Icon(Icons.error);
    } else if (snapshot.data.scanning) {
      return refreshIndicator();
    } else {
      return Container();
    }
  }

  Widget refreshIndicator() =>
      RefreshProgressIndicator(backgroundColor: Colors.deepOrange);
}

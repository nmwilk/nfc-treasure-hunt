import 'package:flutter/material.dart';
import 'package:treasure_nfc/src/model/app_models.dart';

class GridCell extends StatelessWidget {
  const GridCell({
    Key key,
    @required this.context,
    @required this.treasureRecord,
  }) : super(key: key);

  final BuildContext context;
  final TreasureRecord treasureRecord;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(color: Colors.amber),
        Image.network(treasureRecord.treasure.imageUrl),
        Container(
          color: treasureRecord.found ? Colors.transparent : Color(0x90000000),
          child: Center(
            child: SizedBox(
              width: 100.0,
              height: 100.0,
              child: CellStatusIcon(found: treasureRecord.found),
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
}

class CellStatusIcon extends StatelessWidget {
  const CellStatusIcon({
    Key key,
    @required this.found,
  }) : super(key: key);

  final bool found;

  @override
  Widget build(BuildContext context) {
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

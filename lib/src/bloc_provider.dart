import 'package:flutter/material.dart';

import 'bloc.dart';

class BlocProvider extends InheritedWidget {
  final Bloc bloc;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  BlocProvider({Key key, Widget child})
      : bloc = Bloc(),
        super(key: key, child: child);

  static Bloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(BlocProvider) as BlocProvider).bloc;
  }
}
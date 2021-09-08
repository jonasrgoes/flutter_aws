import 'package:flutter/material.dart';

import 'package:flutter_aws/src/blocs/finance/bloc.dart';

class UserFinanceBlocProvider extends InheritedWidget {
  final bloc = UserFinanceBloc();

  UserFinanceBlocProvider({Key? key, required Widget child}) : super(key: key, child: child);

  @override
  // ignore: avoid_renaming_method_parameters
  bool updateShouldNotify(_) => true;

  static UserFinanceBloc of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<UserFinanceBlocProvider>())!.bloc;
  }
}

import 'package:flutter/material.dart';

import 'package:flutter_aws/src/blocs/authentication/bloc.dart';

class AuthenticationBlocProvider extends InheritedWidget {
  final bloc = AuthenticationBloc();

  AuthenticationBlocProvider({Key? key, required Widget child}) : super(key: key, child: child);

  @override
  // ignore: avoid_renaming_method_parameters
  bool updateShouldNotify(InheritedWidget _) {
    return true;
  }

  static AuthenticationBloc of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<AuthenticationBlocProvider>())!.bloc;
  }
}

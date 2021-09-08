import 'package:flutter/material.dart';

import 'package:flutter_aws/src/models/user.dart';

import 'package:flutter_aws/src/blocs/authentication/provider.dart';

import 'package:flutter_aws/src/ui/home/home_page.dart';
import 'package:flutter_aws/src/ui/authentication/login_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  static const String routeName = 'root_page';

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  // final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = AuthenticationBlocProvider.of(context);

    return StreamBuilder<User?>(
      stream: authProvider.user,
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasData) {
          print('$snapshot');
          print('USER confirmed: ${snapshot.data!.confirmed}');
        }
        return snapshot.hasData && snapshot.data!.confirmed ? const HomePage() : const LoginPage();
      },
    );
  }
}

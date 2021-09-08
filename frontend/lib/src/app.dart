import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_aws/src/root_page.dart';

import 'package:flutter_aws/src/blocs/authentication/provider.dart';
import 'package:flutter_aws/src/blocs/finance/provider.dart';

import 'package:flutter_aws/src/ui/home/home_page.dart';
import 'package:flutter_aws/src/ui/home/finance_history_page.dart';
import 'package:flutter_aws/src/ui/authentication/login_page.dart';

import 'package:flutter_aws/src/utils/values/colors.dart';

class FlutterAWS extends StatelessWidget {
  const FlutterAWS({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AuthenticationBlocProvider(
      key: key,
      child: UserFinanceBlocProvider(
        key: key,
        child: MaterialApp(
          title: 'FLutter AWS',
          theme: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(primary: ColorConstant.colorMainPurple),
          ),
          //fontFamily: 'SF Pro Display'
          initialRoute: RootPage.routeName,
          routes: <String, Widget Function(BuildContext)>{
            RootPage.routeName: (BuildContext context) => const RootPage(),
            LoginPage.routeName: (BuildContext context) => const LoginPage(),
            HomePage.routeName: (BuildContext context) => const HomePage(),
            FinanceHistoryPage.routeName: (BuildContext context) => const FinanceHistoryPage()
          },
        ),
      ),
    );
  }
}

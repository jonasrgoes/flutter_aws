// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aws/src/blocs/authentication/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_aws/src/ui/home/home_page_content.dart';

import 'package:flutter_aws/src/models/user.dart';

import 'package:flutter_aws/src/blocs/finance/bloc.dart';
import 'package:flutter_aws/src/blocs/finance/provider.dart';

import 'package:flutter_aws/src/utils/values/colors.dart';
import 'package:flutter_aws/src/utils/values/assets.dart';

class HomePage extends StatefulWidget {
  static const String routeName = 'home_page';

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  UserFinanceBloc? _userFinanceBloc;
  SharedPreferences? _prefs;

  @override
  void didChangeDependencies() {
    _userFinanceBloc = UserFinanceBlocProvider.of(context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = AuthenticationBlocProvider.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorConstant.colorMainPurple,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      height: 40.0,
                      margin: const EdgeInsets.only(top: 50, right: 10.0),
                      child: Image.asset(
                        AssetsConstants.nulogo,
                        color: Colors.white,
                      )),
                  StreamBuilder<User?>(
                    stream: authProvider.user,
                    builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
                      if (snapshot.hasData) {
                        User? user = snapshot.data;

                        String? displayName = user!.name;

                        displayName ??= _userFinanceBloc!.getCurrentUserDisplayNameFromPrefs(_prefs!);

                        return Container(
                          height: 50.0,
                          margin: const EdgeInsets.only(top: 50.0, left: 10.0),
                          alignment: Alignment.center,
                          child: Text(
                            displayName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
              Container(
                  height: 35.0,
                  margin: const EdgeInsets.only(top: 10.0, bottom: 5),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white70,
                  )),
            ],
          ),
          const HomePageContent()
        ],
      ),
    );
  }
}

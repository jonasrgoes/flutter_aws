import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_aws/src/models/user.dart';

import 'package:flutter_aws/src/blocs/authentication/bloc.dart';
import 'package:flutter_aws/src/blocs/authentication/provider.dart';

import 'package:flutter_aws/src/ui/widgets/forms/form_field_main.dart';
import 'package:flutter_aws/src/ui/widgets/actions/button_transparent_main.dart';

import 'package:flutter_aws/src/utils/values/colors.dart';
import 'package:flutter_aws/src/utils/values/string_constants.dart';
import 'package:flutter_aws/src/utils/values/assets.dart';

const double minHeight = 60.0;
const double maxHeight = 600.0;
const double minWidth = 250.0;
const double maxWidth = 400.0;
const double maxBottomButtonsMargin = 15;
const double minBottomButtonsMargin = -170;
const double maxFormsContainerMargin = 160;
const double minFormsContainerMargin = 20;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  static const String routeName = 'login_page';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late AuthenticationBloc _authBloc;
  late SharedPreferences _prefs;

  late AnimationController _controller;

  bool _loginContainerOpened = false;
  bool _signUpContainerOpened = false;

  double _loginContainerHeight = minHeight;
  double _loginContainerWidth = minWidth;

  double _signUpContainerHeight = minHeight;
  double _signUpContainerWidth = minWidth;

  double _formsContainerMargin = maxFormsContainerMargin;

  @override
  void didChangeDependencies() {
    _authBloc = AuthenticationBlocProvider.of(context);
    _authBloc.showConfirm(false);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _authBloc.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleAuthButtonsScale(bool isLogin) {
    setState(() {
      if (isLogin) {
        _loginContainerHeight = _loginContainerHeight == maxHeight ? minHeight : maxHeight;
        _loginContainerWidth = _loginContainerWidth == maxWidth ? minWidth : maxWidth;
        _scaleDownSignUpBtn();
        _loginContainerOpened = !_loginContainerOpened;
      } else {
        _signUpContainerHeight = _signUpContainerHeight == maxHeight ? minHeight : maxHeight;
        _signUpContainerWidth = _signUpContainerWidth == maxWidth ? minWidth : maxWidth;
        _scaleDownLoginBtn();
        _signUpContainerOpened = !_signUpContainerOpened;
      }

      _formsContainerMargin =
          _formsContainerMargin == minFormsContainerMargin ? maxFormsContainerMargin : minFormsContainerMargin;
    });
  }

  void _scaleDownSignUpBtn() {
    if (_signUpContainerOpened) {
      _signUpContainerHeight = minHeight;
      _signUpContainerWidth = minWidth;
      _signUpContainerOpened = false;
    }
  }

  void _scaleDownLoginBtn() {
    if (_loginContainerOpened) {
      _loginContainerHeight = minHeight;
      _loginContainerWidth = minWidth;
      _loginContainerOpened = false;
    }
  }

  void _toggleNuLogoAndGoogleBtn() {
    final bool isAnyContainerExpanded = _controller.status == AnimationStatus.completed;

    _controller.fling(velocity: isAnyContainerExpanded ? -2 : 2);
  }

  void showErrorMessage(String message) {
    debugPrint(message);

    final snackbar = SnackBar(content: Text(message), duration: const Duration(seconds: 2));

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  double? lerp(double min, double max) => lerpDouble(min, max, _controller.value);

  @override
  Widget build(BuildContext context) {
    debugPrint('Build Login Page');

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: ColorConstant.colorMainPurple,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: <Widget>[
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned.fill(
                  top: lerp(maxBottomButtonsMargin, minBottomButtonsMargin),
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: <Widget>[
                          Container(
                              height: 60.0,
                              margin: const EdgeInsets.only(top: 50.0),
                              child: Image.asset(
                                'assets/images/nulogo.png',
                                color: Colors.white,
                              )),
                          Container(
                              height: 60.0,
                              margin: const EdgeInsets.only(top: 10.0, bottom: 5),
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white70,
                              )),
                        ],
                      )),
                );
              },
            ),
            ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                  margin: EdgeInsets.only(top: _formsContainerMargin),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      /// SIGN UP
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _loginContainerOpened
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  if (!_signUpContainerOpened && !_loginContainerOpened) {
                                    _toggleAuthButtonsScale(false);
                                    _toggleNuLogoAndGoogleBtn();
                                  }
                                },
                                child: AnimatedContainer(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(top: 5.0),
                                  width: _signUpContainerWidth,
                                  height: _signUpContainerHeight,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.fastOutSlowIn,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: _signUpContainerOpened
                                        ? Container(
                                            alignment: Alignment.topCenter,
                                            child: Stack(
                                              children: <Widget>[
                                                Positioned(
                                                  top: 5,
                                                  left: 5,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      if (_signUpContainerOpened) {
                                                        _toggleAuthButtonsScale(false);
                                                        _toggleNuLogoAndGoogleBtn();
                                                      }
                                                    },
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 40.0,
                                                    ),
                                                  ),
                                                ),
                                                Positioned.fill(
                                                  top: 70.0,
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Column(
                                                      children: <Widget>[
                                                        StreamBuilder(
                                                            stream: _authBloc.email,
                                                            builder: (context, snapshot) {
                                                              debugPrint('snapshot.hasData: ${snapshot.hasData}');
                                                              debugPrint('snapshot.data: ${snapshot.data.toString()}');
                                                              debugPrint('snapshot.hasError: ${snapshot.hasError}');
                                                              debugPrint(
                                                                  'snapshot.error: ${snapshot.error.toString()}');

                                                              return FormFieldMain(
                                                                hintText: StringConstants.email,
                                                                onChanged: _authBloc.changeEmail,
                                                                errorText:
                                                                    snapshot.hasError ? snapshot.error.toString() : '',
                                                                marginLeft: 20.0,
                                                                marginRight: 20.0,
                                                                marginTop: 0,
                                                                textInputType: TextInputType.text,
                                                                obscured: false,
                                                              );
                                                            }),
                                                        StreamBuilder(
                                                          stream: _authBloc.password,
                                                          builder: (context, snapshot) {
                                                            debugPrint('snapshot.hasData: ${snapshot.hasData}');
                                                            debugPrint('snapshot.data: ${snapshot.data.toString()}');
                                                            debugPrint('snapshot.hasError: ${snapshot.hasError}');
                                                            debugPrint('snapshot.error: ${snapshot.error.toString()}');

                                                            return FormFieldMain(
                                                              onChanged: _authBloc.changePassword,
                                                              errorText:
                                                                  snapshot.hasError ? snapshot.error.toString() : '',
                                                              hintText: StringConstants.password,
                                                              marginLeft: 20.0,
                                                              marginRight: 20.0,
                                                              marginTop: 15.0,
                                                              textInputType: TextInputType.text,
                                                              obscured: true,
                                                            );
                                                          },
                                                        ),
                                                        StreamBuilder(
                                                          stream: _authBloc.displayName,
                                                          builder: (context, snapshot) {
                                                            debugPrint('snapshot.hasData: ${snapshot.hasData}');
                                                            debugPrint('snapshot.data: ${snapshot.data.toString()}');
                                                            debugPrint('snapshot.hasError: ${snapshot.hasError}');
                                                            debugPrint('snapshot.error: ${snapshot.error.toString()}');

                                                            return FormFieldMain(
                                                              onChanged: _authBloc.changeDisplayName,
                                                              errorText:
                                                                  snapshot.hasError ? snapshot.error.toString() : '',
                                                              hintText: StringConstants.displayName,
                                                              marginLeft: 20.0,
                                                              marginRight: 20.0,
                                                              marginTop: 15.0,
                                                              textInputType: TextInputType.text,
                                                              obscured: false,
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Positioned.fill(
                                                  bottom: 15,
                                                  child: Align(
                                                    alignment: Alignment.bottomCenter,
                                                    child: StreamBuilder(
                                                        stream: _authBloc.signInStatus,
                                                        builder: (context, snapshot) {
                                                          debugPrint(snapshot.toString());
                                                          debugPrint(
                                                              'snapshot.hasData.toString(): ${snapshot.hasData.toString()}');
                                                          debugPrint(
                                                              'snapshot.hasError.toString(): ${snapshot.hasError.toString()}');
                                                          if (!snapshot.hasData || snapshot.hasError) {
                                                            return ButtonTransparentMain(
                                                              callback: () async {
                                                                // debugDumpApp();
                                                                debugPrint('_authBloc.signInStatus');
                                                                if (_authBloc.validateEmailAndPassword() &&
                                                                    _authBloc.validateDisplayName()) {
                                                                  _authBloc.saveCurrentUserDisplayName(_prefs);
                                                                  User? response = await _authBloc.registerUser();

                                                                  if (response != null) {
                                                                    showErrorMessage(
                                                                        StringConstants.emailOrPasswordIncorrect);
                                                                  } else {
                                                                    // TODO: send email confirmation
                                                                  }
                                                                } else {
                                                                  showErrorMessage(StringConstants.fillUpFormCorrectly);
                                                                }
                                                              },
                                                              height: 60.0,
                                                              width: MediaQuery.of(context).size.width,
                                                              fontSize: 20.0,
                                                              marginRight: 30.0,
                                                              marginLeft: 30.0,
                                                              text: 'Sign Up',
                                                              borderColor: ColorConstant.colorMainPurple,
                                                              textColor: ColorConstant.colorMainPurple,
                                                            );
                                                          } else {
                                                            return const CircularProgressIndicator(
                                                              backgroundColor: Colors.white,
                                                            );
                                                          }
                                                        }),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : const Text(
                                            'Sign Up',
                                            style: TextStyle(
                                                color: Colors.black54, fontWeight: FontWeight.w400, fontSize: 25.0),
                                          ),
                                  ),
                                ),
                              ),
                      ),

                      /// LOGIN
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _signUpContainerOpened
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  if (!_loginContainerOpened && !_signUpContainerOpened) {
                                    _toggleAuthButtonsScale(true);
                                    _toggleNuLogoAndGoogleBtn();
                                  }
                                },
                                child: AnimatedContainer(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(top: 5.0),
                                  width: _loginContainerWidth,
                                  height: _loginContainerHeight,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.fastOutSlowIn,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: _loginContainerOpened
                                        ? Container(
                                            alignment: Alignment.topCenter,
                                            child: Stack(
                                              children: <Widget>[
                                                /// Close button ------
                                                Positioned(
                                                  top: 5,
                                                  left: 5,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      if (_loginContainerOpened) {
                                                        _toggleAuthButtonsScale(true);
                                                        _toggleNuLogoAndGoogleBtn();
                                                      }
                                                    },
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 40.0,
                                                    ),
                                                  ),
                                                ),

                                                /// End Close Button ------

                                                Positioned.fill(
                                                  top: 70.0,
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Column(
                                                      children: <Widget>[
                                                        /// EMAIL
                                                        StreamBuilder(
                                                            stream: _authBloc.confirm,
                                                            builder: (context, snapshot) {
                                                              if (snapshot.hasData && snapshot.data == false) {
                                                                return StreamBuilder(
                                                                  stream: _authBloc.email,
                                                                  builder: (context, snapshot) {
                                                                    debugPrint('snapshot.hasData: ${snapshot.hasData}');
                                                                    debugPrint(
                                                                        'snapshot.data: ${snapshot.data.toString()}');
                                                                    debugPrint(
                                                                        'snapshot.hasError: ${snapshot.hasError}');
                                                                    debugPrint(
                                                                        'snapshot.error: ${snapshot.error.toString()}');

                                                                    return FormFieldMain(
                                                                      onChanged: _authBloc.changeEmail,
                                                                      errorText: snapshot.hasError
                                                                          ? snapshot.error.toString()
                                                                          : '',
                                                                      hintText: StringConstants.email,
                                                                      marginLeft: 20.0,
                                                                      marginRight: 20.0,
                                                                      marginTop: 0,
                                                                      textInputType: TextInputType.text,
                                                                      obscured: false,
                                                                    );
                                                                  },
                                                                );
                                                              } else {
                                                                return Container();
                                                              }
                                                            }),

                                                        /// PASSWORD
                                                        StreamBuilder(
                                                            stream: _authBloc.confirm,
                                                            builder: (context, snapshot) {
                                                              if (snapshot.hasData && snapshot.data == false) {
                                                                return StreamBuilder(
                                                                  stream: _authBloc.password,
                                                                  builder: (context, snapshot) {
                                                                    debugPrint('snapshot.hasData: ${snapshot.hasData}');
                                                                    debugPrint(
                                                                        'snapshot.data: ${snapshot.data.toString()}');
                                                                    debugPrint(
                                                                        'snapshot.hasError: ${snapshot.hasError}');
                                                                    debugPrint(
                                                                        'snapshot.error: ${snapshot.error.toString()}');

                                                                    return FormFieldMain(
                                                                      onChanged: _authBloc.changePassword,
                                                                      errorText: snapshot.hasError
                                                                          ? snapshot.error.toString()
                                                                          : '',
                                                                      hintText: StringConstants.password,
                                                                      marginLeft: 20.0,
                                                                      marginRight: 20.0,
                                                                      marginTop: 15.0,
                                                                      textInputType: TextInputType.text,
                                                                      obscured: true,
                                                                    );
                                                                  },
                                                                );
                                                              } else {
                                                                return Container();
                                                              }
                                                            }),

                                                        /// CONFIRMATION CODE
                                                        StreamBuilder(
                                                            stream: _authBloc.confirm,
                                                            builder: (context, snapshot) {
                                                              if (snapshot.hasData && snapshot.data == true) {
                                                                return StreamBuilder(
                                                                    stream: _authBloc.code,
                                                                    builder: (context, snapshot) {
                                                                      debugPrint(
                                                                          'snapshot.hasData: ${snapshot.hasData}');
                                                                      debugPrint(
                                                                          'snapshot.data: ${snapshot.data.toString()}');
                                                                      debugPrint(
                                                                          'snapshot.hasError: ${snapshot.hasError}');
                                                                      debugPrint(
                                                                          'snapshot.error: ${snapshot.error.toString()}');

                                                                      return FormFieldMain(
                                                                        onChanged: _authBloc.changeCode,
                                                                        errorText: snapshot.hasError
                                                                            ? snapshot.error.toString()
                                                                            : '',
                                                                        hintText: StringConstants.confirmationCode,
                                                                        marginLeft: 20.0,
                                                                        marginRight: 20.0,
                                                                        marginTop: 15.0,
                                                                        textInputType: TextInputType.text,
                                                                        obscured: false,
                                                                      );
                                                                    });
                                                              } else {
                                                                return Container();
                                                              }
                                                            }),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                /// LOGIN AND CONFIRM BUTTONS
                                                Positioned.fill(
                                                  bottom: 15,
                                                  child: Align(
                                                    alignment: Alignment.bottomCenter,
                                                    child: StreamBuilder(
                                                        stream: _authBloc.signInStatus,
                                                        builder: (context, snapshot) {
                                                          String btnText = 'Login';

                                                          if (!snapshot.hasData ||
                                                              snapshot.hasError ||
                                                              snapshot.data as bool == false) {
                                                            return ButtonTransparentMain(
                                                              callback: () async {
                                                                bool confirm = _authBloc.isConfirmed;

                                                                /// VALIDATES CONFIRMATION CODE
                                                                if (confirm == true) {
                                                                  print('VALIDATING CONFIRMATION CODE');

                                                                  btnText = 'Confirm';

                                                                  if (_authBloc.validateConfirmationCode()) {
                                                                    var response = await _authBloc.confirmAccount();

                                                                    if (response == true) {
                                                                    } else {
                                                                      showErrorMessage(
                                                                          StringConstants.confirmationCodeInvalid);
                                                                    }
                                                                  } else {
                                                                    print('CONFIRMATION CODE NOT VALIDATED');
                                                                    showErrorMessage(
                                                                        StringConstants.fillUpCodeCorrectly);
                                                                  }

                                                                  /// VALIDATES LOGIN
                                                                } else {
                                                                  print('VALIDATING LOGIN');

                                                                  btnText = 'Login';

                                                                  if (_authBloc.validateEmailAndPassword()) {
                                                                    print('LOGIN WAS VALIDATED!');

                                                                    var response = await _authBloc.loginUser();

                                                                    if (response == null) {
                                                                      showErrorMessage('Null response received!');
                                                                    } else if (response == -1) {
                                                                      showErrorMessage(
                                                                          StringConstants.emailOrPasswordIncorrect);
                                                                      _authBloc.showConfirm(false);
                                                                    } else if (response == -2) {
                                                                      showErrorMessage(
                                                                          StringConstants.confirmationCode);
                                                                      _authBloc.showConfirm(true);
                                                                    }
                                                                  } else {
                                                                    print('EMAIL AND PASSWORD ARE NOT VALIDATED');
                                                                    showErrorMessage(
                                                                        StringConstants.fillUpFormCorrectly);
                                                                  }
                                                                }
                                                              },
                                                              height: 60.0,
                                                              width: MediaQuery.of(context).size.width,
                                                              fontSize: 20.0,
                                                              marginRight: 30.0,
                                                              marginLeft: 30.0,
                                                              text: btnText,
                                                              borderColor: ColorConstant.colorMainPurple,
                                                              textColor: ColorConstant.colorMainPurple,
                                                            );
                                                          } else {
                                                            return const CircularProgressIndicator(
                                                              backgroundColor: Colors.white,
                                                            );
                                                          }
                                                        }),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : const Text(
                                            'Login',
                                            style: TextStyle(
                                                color: Colors.black54, fontWeight: FontWeight.w400, fontSize: 25.0),
                                          ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// GOOGLE
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned.fill(
                  bottom: lerp(maxBottomButtonsMargin, minBottomButtonsMargin),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15.0),
                          height: 55.0,
                          child: ClipOval(
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              color: Colors.white,
                              child: Image.asset(AssetsConstants.google),
                            ),
                          ),
                        )),
                  ),
                );
              },
            ),
          ],
        ));
  }
}

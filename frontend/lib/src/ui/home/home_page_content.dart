import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_aws/src/blocs/finance/bloc.dart';
import 'package:flutter_aws/src/blocs/finance/provider.dart';
import 'package:flutter_aws/src/models/expense.dart';
import 'package:flutter_aws/src/models/finance.dart';
import 'package:flutter_aws/src/ui/widgets/actions/bottom_action_button.dart';
import 'package:flutter_aws/src/ui/widgets/actions/options_buttons.dart';
import 'package:flutter_aws/src/utils/values/colors.dart';
import 'package:flutter_aws/src/utils/values/string_constants.dart';
import 'package:flutter_aws/src/ui/widgets/actions/button_transparent_main.dart';
import 'package:flutter_aws/src/ui/widgets/forms/form_field_main.dart';
import 'package:flutter_aws/src/ui/home/finance_history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double minTop = 145;
const double maxQuickActionsMargin = 50;
const double minQuickActionsMargin = -170;

class HomePageContent extends StatefulWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  UserFinanceBloc? _userFinanceBloc;

  late SharedPreferences _prefs;

  bool _hideOptions = true;
  bool _isUserBudgetAlreadySet = false;

  double _expenseProgressValue = .0;

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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _controller!.dispose();

    super.dispose();
  }

  void showErrorMessage(BuildContext context, String message) {
    debugPrint('Error Message: $message');

    final snackbar = SnackBar(content: Text(message), duration: const Duration(seconds: 2));

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _controller!.value += (details.primaryDelta ?? .0) / minTop;
    debugPrint("VALUE: ${_controller!.value}");

    if (_controller!.value > .5) {
      _hideOptions = false;
    } else {
      _hideOptions = true;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller!.isAnimating || _controller!.status == AnimationStatus.completed) return;

    if (_controller!.value > 0.5) {
      _controller!.fling(velocity: 2);
    } else {
      _controller!.fling(velocity: -2);
    }
  }

  double? lerp(double min, double max) => lerpDouble(min, max, _controller!.value);

  void _insertNewQuickActionModal(BuildContext context, String title, VoidCallback confirmCallback) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * .7,
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(
                    Icons.money_off,
                    size: 35.0,
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontSize: 26.0),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  child: ListTile(
                    title: StreamBuilder(
                      stream: _userFinanceBloc!.financeValue,
                      builder: (context, snapshot) {
                        debugPrint('snapshot.hasData: ${snapshot.hasData}');
                        debugPrint('snapshot.data: ${snapshot.data.toString()}');
                        debugPrint('snapshot.hasError: ${snapshot.hasError}');
                        debugPrint('snapshot.error: ${snapshot.error.toString()}');

                        return FormFieldMain(
                          hintText: 'Valor...',
                          onChanged: _userFinanceBloc!.changeFinanceValue,
                          errorText: snapshot.hasError ? snapshot.error.toString() : '',
                          marginLeft: 20.0,
                          marginRight: 20.0,
                          marginTop: 0,
                          textInputType: TextInputType.number,
                          obscured: false,
                        );
                      },
                    ),
                    onTap: () => {},
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 50.0),
                  child: ListTile(
                    leading: const Icon(
                      Icons.done,
                      size: 28.0,
                    ),
                    title: const Text(
                      StringConstants.confirm,
                      style: TextStyle(fontSize: 20.0),
                    ),
                    onTap: () {
                      debugPrint('confirmCallback');
                      confirmCallback();
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double maxTop = MediaQuery.of(context).size.height * .9;

    _userFinanceBloc!.updateFinanceDoc();

    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) {
        return Stack(
          children: <Widget>[
            Positioned(
              height: MediaQuery.of(context).size.height * .60,
              left: 0,
              right: 0,
              top: minTop,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _hideOptions == false
                    ? Padding(
                        padding: const EdgeInsets.all(35.0),
                        child: Column(
                          children: <Widget>[
                            const Divider(
                              color: Colors.white70,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            const OptionsButton(
                              icon: Icons.help_outline,
                              text: StringConstants.about,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            const Divider(
                              color: Colors.white70,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            const OptionsButton(icon: Icons.perm_identity, text: StringConstants.profile),
                            const SizedBox(
                              height: 10.0,
                            ),
                            const Divider(
                              color: Colors.white70,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            const OptionsButton(
                              icon: Icons.settings,
                              text: StringConstants.settings,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            const Divider(
                              color: Colors.white70,
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            ButtonTransparentMain(
                              callback: () {
                                _userFinanceBloc!.signOut();
                              },
                              fontSize: 20.0,
                              height: 50,
                              marginLeft: 0,
                              marginRight: 0,
                              text: StringConstants.logout,
                              borderColor: Colors.white70,
                              textColor: Colors.white70,
                            )
                          ],
                        ),
                      )
                    : Container(),
              ),
            ),
            Positioned(
              height: MediaQuery.of(context).size.height * .45,
              left: 0,
              right: 0,
              top: lerp(minTop, maxTop),
              child: GestureDetector(
                onVerticalDragUpdate: _handleDragUpdate,
                onVerticalDragEnd: _handleDragEnd,
                onTap: () {
                  if (_hideOptions) {
                    Navigator.pushNamed(context, FinanceHistoryPage.routeName, arguments: _expenseProgressValue);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(8)),
                  ),
                  child: FutureBuilder<String?>(
                    future: _userFinanceBloc!.getUserUID(),
                    builder: (context, userUID) {
                      if (!userUID.hasData || userUID.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          ),
                        );
                      } else {
                        return StreamBuilder<FinanceModel>(
                          stream: _userFinanceBloc!.financeDoc,
                          builder: (context, snapshot) {
                            debugPrint('totalSpent snapshot.hasData: ${snapshot.hasData}');
                            debugPrint('totalSpent snapshot.data: ${snapshot.data.toString()}');
                            debugPrint('totalSpent snapshot.hasError: ${snapshot.hasError}');
                            debugPrint('totalSpent snapshot.error: ${snapshot.error.toString()}');

                            // debugPrint('totalSpent snapshot.data: ${snapshot.data!['totalSpent']}');

                            double totalSpent;
                            double budget;

                            if (snapshot.hasData) {
                              totalSpent = snapshot.data!.totalSpent;
                              budget = snapshot.data!.budget;

                              double availableLimit = budget - totalSpent;

                              if (availableLimit < 0) availableLimit = 0;

                              _expenseProgressValue = totalSpent / budget;

                              _isUserBudgetAlreadySet = true;
                              return Stack(
                                children: <Widget>[
                                  const Positioned(
                                    top: 16,
                                    left: 16,
                                    child: Icon(
                                      Icons.credit_card,
                                      color: Colors.black38,
                                      size: 32.0,
                                    ),
                                  ),
                                  Positioned(
                                    top: MediaQuery.of(context).size.height * .14,
                                    left: 16,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text(
                                          StringConstants.currentExpense,
                                          style: TextStyle(
                                              color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 15.0),
                                        ),
                                        Text(
                                          "R\$ " + totalSpent.toString(),
                                          style: const TextStyle(
                                              color: Colors.orange, fontWeight: FontWeight.w400, fontSize: 30.0),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            const Text(
                                              StringConstants.limit,
                                              style: TextStyle(
                                                  color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 15.0),
                                            ),
                                            Text(
                                              " R\$ " + availableLimit.toString(),
                                              style: const TextStyle(
                                                  color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15.0),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 25,
                                    top: 20,
                                    child: Hero(
                                      tag: 'progress-budget',
                                      child: RotatedBox(
                                        quarterTurns: 1,
                                        child: SizedBox(
                                          height: 10,
                                          width: MediaQuery.of(context).size.height * .25,
                                          child: LinearProgressIndicator(
                                            backgroundColor: Colors.green,
                                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                                            value: _expenseProgressValue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    height: 90.0,
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      color: Colors.black12,
                                      child: StreamBuilder(
                                        stream: _userFinanceBloc!.lastExpense(userUID.data),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData && snapshot.data != null) {
                                            ExpenseModel lastExpense = snapshot.data as ExpenseModel;

                                            return Center(
                                              child: Column(
                                                children: <Widget>[
                                                  const Text(
                                                    StringConstants.mostRecentExpense,
                                                    style: TextStyle(
                                                        color: Colors.black87,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 15.0),
                                                  ),
                                                  Text(
                                                    "R\$ " + lastExpense.value.toString(),
                                                    style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 15.0),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            return const Center(
                                              child: Text(
                                                StringConstants.noRecentExpenses,
                                                style: TextStyle(
                                                    color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 15.0),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              _isUserBudgetAlreadySet = false;
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    const Text(
                                      StringConstants.requireMonthlyBudget,
                                      style:
                                          TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 15.0),
                                    ),
                                    const SizedBox(
                                      height: 30.0,
                                    ),
                                    ButtonTransparentMain(
                                      callback: () async {
                                        _insertNewQuickActionModal(context, "Set monthly Budget", () {
                                          if (_userFinanceBloc!.validateFinance()) {
                                            _userFinanceBloc!.setUserBudget(_prefs);
                                            Navigator.of(context).pop();
                                          } else {
                                            debugPrint('validateFinance failed!');
                                          }
                                        });
                                      },
                                      height: 60.0,
                                      width: MediaQuery.of(context).size.width,
                                      fontSize: 20.0,
                                      marginRight: 40.0,
                                      marginLeft: 40.0,
                                      text: StringConstants.setMonthlyBudget,
                                      borderColor: ColorConstant.colorMainPurple,
                                      textColor: ColorConstant.colorMainPurple,
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              height: 145,
              left: 0,
              right: 0,
              bottom: lerp(maxQuickActionsMargin, minQuickActionsMargin),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  BottomActionButton(
                    icon: Icons.money_off,
                    iconSize: 32.0,
                    actionText: StringConstants.insertExpense,
                    callback: () {
                      debugPrint('_isUserBudgetAlreadySet $_isUserBudgetAlreadySet');
                      if (_isUserBudgetAlreadySet) {
                        _insertNewQuickActionModal(context, "Incluir Despesa", () async {
                          debugPrint('_userFinanceBloc!.validateFinance() ${_userFinanceBloc!.validateFinance()}');
                          if (_userFinanceBloc!.validateFinance()) {
                            debugPrint('validateFinance ok!');
                            await _userFinanceBloc!.addNewExpense();
                            Navigator.of(context).pop();
                          } else {
                            debugPrint('validateFinance failed!');
                          }
                        });
                      } else {
                        showErrorMessage(context, StringConstants.requireMonthlyBudget);
                      }
                    },
                  ),
                  BottomActionButton(
                      icon: Icons.monetization_on,
                      iconSize: 32.0,
                      actionText: StringConstants.monthlyBudget,
                      callback: () {
                        _insertNewQuickActionModal(context, StringConstants.setMonthlyBudget, () {
                          if (_userFinanceBloc!.validateFinance()) {
                            _userFinanceBloc!.setUserBudget(_prefs);
                            // _userFinanceBloc!.userFinanceDoc(userUID.data);
                            Navigator.of(context).pop();
                          } else {
                            debugPrint('validateFinance failed!');
                          }
                        });
                      }),
                  BottomActionButton(
                    icon: Icons.group_add,
                    iconSize: 32.0,
                    actionText: StringConstants.tellAFriend,
                    callback: () {},
                  ),
                  BottomActionButton(
                    icon: Icons.help_outline,
                    iconSize: 32.0,
                    actionText: StringConstants.about,
                    callback: () {},
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

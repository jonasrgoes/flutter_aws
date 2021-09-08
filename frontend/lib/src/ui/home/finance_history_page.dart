import 'package:flutter/material.dart';

import 'package:flutter_aws/src/ui/widgets/expense/card.dart';

import 'package:flutter_aws/src/models/expense.dart';

import 'package:flutter_aws/src/blocs/finance/bloc.dart';
import 'package:flutter_aws/src/blocs/finance/provider.dart';

import 'package:flutter_aws/src/utils/values/string_constants.dart';

class FinanceHistoryPage extends StatefulWidget {
  static const String routeName = 'finance_history_page';

  const FinanceHistoryPage({Key? key}) : super(key: key);

  @override
  _FinanceHistoryPageState createState() => _FinanceHistoryPageState();
}

class _FinanceHistoryPageState extends State<FinanceHistoryPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  UserFinanceBloc? _userFinanceBloc;

  @override
  void didChangeDependencies() {
    _userFinanceBloc = UserFinanceBlocProvider.of(context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double expenseProgressValue = ModalRoute.of(context)!.settings.arguments as double;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: SizedBox(height: 40, child: Image.asset('assets/images/nulogo.png', fit: BoxFit.fitHeight)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black87,
          iconSize: 45.0,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 15.0),
            child: FutureBuilder<String?>(
                future: _userFinanceBloc?.getUserUID(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
                    );
                  } else {
                    return StreamBuilder<List<ExpenseModel>>(
                        stream: _userFinanceBloc!.expenseList(snapshot.data),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(snapshot.error.toString()),
                            );
                          } else if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                            List<ExpenseModel> expensesList = snapshot.data as List<ExpenseModel>;

                            return ListView.builder(
                                itemCount: expensesList.length,
                                itemBuilder: (context, position) {
                                  return ExpenseCard(
                                      value: expensesList[position].value.toString(),
                                      isLastOne: position == expensesList.length - 1);
                                });
                          } else {
                            // No data -- Error
                            return const Center(
                              child: Text(StringConstants.noExpenses),
                            );
                          }
                        });
                  }
                }),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Hero(
              tag: 'progress-budget',
              child: RotatedBox(
                quarterTurns: 1,
                child: SizedBox(
                  height: 10,
                  width: MediaQuery.of(context).size.height,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.green,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                    value: expenseProgressValue,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

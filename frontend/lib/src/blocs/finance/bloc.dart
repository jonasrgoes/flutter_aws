import 'dart:async';

import 'package:flutter_aws/src/models/expense.dart';
import 'package:flutter_aws/src/models/finance.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_aws/src/blocs/bloc.dart';
import 'package:flutter_aws/src/utils/prefs_manager.dart';
import 'package:flutter_aws/src/utils/validator.dart';
import 'package:flutter_aws/src/utils/values/string_constants.dart';

import 'package:flutter_aws/src/resources/repository.dart';

class UserFinanceBloc implements Bloc {
  final _repository = Repository();
  final _financeValue = BehaviorSubject<String>();

  Stream<String> get financeValue => _financeValue.stream.transform(_validateFinanceValue);

  Function(String) get changeFinanceValue => _financeValue.sink.add;

  final _validateFinanceValue = StreamTransformer<String, String>.fromHandlers(handleData: (value, sink) {
    if (Validator.validateFinanceValue(value)) {
      sink.add(value);
    } else {
      sink.addError(StringConstants.financeValueValidateMessage);
    }
  });

  bool validateFinance() {
    return _financeValue.hasValue && _financeValue.value.isNotEmpty;
  }

  Future<String?> getUserUID() => _repository.getUserUID();

  Future<void> signOut() => _repository.signOut();

  String getCurrentUserDisplayNameFromPrefs(SharedPreferences prefs) {
    PrefsManager prefsMang = PrefsManager();
    String? displayName = prefsMang.getCurrentUserDisplayName(prefs);
    print("CURRENT DISPLAYNAME: " + displayName!);
    return displayName;
  }

  Stream<FinanceModel> userFinanceDoc(String? userUID) => _repository.userFinanceDoc(userUID!);

  Future<void> setUserBudget(SharedPreferences prefs) async {
    String? userUID = await getUserUID();

    // TODO: returns Stream<double>
    _repository.setUserBudget(prefs, double.tryParse(_financeValue.value));
  }

  Stream<List<ExpenseModel>> expenseList(String? userUID) => _repository.expensesList(userUID!);

  Stream<ExpenseModel?> lastExpense(String? userUID) => _repository.lastExpense(userUID!);

  Future<void> addNewExpense() async {
    String? userUID = await getUserUID();

    print('userUID $userUID');
    print('Value: ${double.tryParse(_financeValue.value)}');

    await _repository.addNewExpense(ExpenseModel(email: userUID!, value: double.parse(_financeValue.value)));

    // TODO: returns Stream<double>
    // _repository.updateTotal(userUID);
  }

  @override
  void dispose() async {
    await _financeValue.drain();
    _financeValue.close();
  }
}

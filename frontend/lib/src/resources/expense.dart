import 'package:flutter_aws/src/models/expense.dart';
import 'package:flutter_aws/src/models/finance.dart';
import 'package:flutter_aws/src/resources/repository.dart';

class ExpenseResources {
  late Repository _repository;

  ExpenseResources() {
    _repository = Repository();
  }

  Stream<FinanceModel> userFinanceDoc(String userUID) async* {
    yield FinanceModel(totalSpent: 150.0, budget: 1500.0);
  }

  Stream<double> setUserBudget(String userUID, double budget) async* {
    yield 1250.40;
  }

  Stream<double> updateTotal(String userUID) async* {
    yield 255.89;
  }

  Future<void> addNewExpense(ExpenseModel expense) async {
    const path = '/expense/add';

    var body = Map<String, dynamic>.from(
        {"email": expense.email, "value": expense.value, "date": expense.date.toIso8601String()});

    var jsonResponse = await _repository.execute(path: path, body: body);

    // Checking API Response Code
    if (jsonResponse?['statusCode'] == '200') {
    } else {
      // An internal server error ocurred
    }
  }

  Stream<List<ExpenseModel>> expensesList(String userUID) async* {
    List<ExpenseModel> expensesList = [];

    const path = '/expense/list';

    var body = Map<String, String>.from({"email": userUID});

    var jsonResponse = await _repository.execute(path: path, body: body);

    if (jsonResponse?['statusCode'] == '200') {
      var jsonItems = jsonResponse?['items'];

      for (int i = 0; i < jsonItems.length; i++) {
        expensesList.add(ExpenseModel.fromJSON(jsonItems[i] as Map<String, dynamic>));
      }

      yield expensesList;
    } else {
      // An internal server error ocurred
      throw Exception('Expenses list error: ${jsonResponse?['error']}');
    }
  }

  Stream<ExpenseModel> lastExpense(String userUID) async* {
    // TODO: Only example
    yield ExpenseModel.fromJSON({'email': '555@gmail.com', 'value': 8.9, 'date': DateTime.now().toIso8601String()});
  }
}

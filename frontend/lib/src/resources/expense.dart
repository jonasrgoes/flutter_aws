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

  Stream<double> total(String userUID) async* {
    const path = '/expense/total';

    var body = Map<String, String>.from({"email": userUID});

    var jsonResponse = await _repository.execute(path: path, body: body);

    if (jsonResponse?['statusCode'] == '200') {
      var jsonItems = jsonResponse?['items'];

      if (jsonItems.length > 0) {
        yield double.parse(jsonItems[0]['total']);
      } else {
        yield 0;
      }
    } else {
      // An internal server error ocurred
      throw Exception('Expense last method error: ${jsonResponse?['error']}');
    }
  }

  Future<void> add(ExpenseModel expense) async {
    const path = '/expense/add';

    var body = Map<String, dynamic>.from({"email": expense.email, "value": expense.value});

    var jsonResponse = await _repository.execute(path: path, body: body);

    // Checking API Response Code
    if (jsonResponse?['statusCode'] == '200') {
    } else {
      // An internal server error ocurred
      throw Exception('Expense add method error: ${jsonResponse?['error']}');
    }
  }

  Stream<List<ExpenseModel>> list(String userUID) async* {
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
      throw Exception('Expenses list method error: ${jsonResponse?['error']}');
    }
  }

  Stream<ExpenseModel?> last(String userUID) async* {
    const path = '/expense/last';

    var body = Map<String, String>.from({"email": userUID});

    var jsonResponse = await _repository.execute(path: path, body: body);

    if (jsonResponse?['statusCode'] == '200') {
      var jsonItems = jsonResponse?['items'];

      if (jsonItems.length > 0) {
        yield ExpenseModel.fromJSON(jsonItems[0] as Map<String, dynamic>);
      } else {
        yield null;
      }
    } else {
      // An internal server error ocurred
      throw Exception('Expense last method error: ${jsonResponse?['error']}');
    }
  }
}

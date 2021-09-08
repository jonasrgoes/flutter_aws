import 'package:flutter_aws/src/models/expense.dart';
import 'package:flutter_aws/src/models/finance.dart';
import 'package:flutter_aws/src/resources/repository.dart';
import 'package:flutter_aws/src/utils/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseResources {
  late Repository _repository;

  late SharedPreferences _sharedPreferences;

  ExpenseResources() {
    _repository = Repository();

    SharedPreferences.getInstance().then((prefs) {
      _sharedPreferences = prefs;
    });
  }

  Stream<FinanceModel> userFinanceDoc(String userUID) async* {
    double totalSpent = await total(userUID);

    double? budget = getUserBudget();

    yield FinanceModel(totalSpent: totalSpent, budget: budget!);
  }

  Future<double> setUserBudget(SharedPreferences prefs, double budget) async {
    PrefsManager prefsManager = PrefsManager();
    prefsManager.setUserBudget(prefs, budget);

    return budget;
  }

  double? getUserBudget() {
    PrefsManager prefsManager = PrefsManager();
    var budget = prefsManager.getUserBudget(_sharedPreferences);
    return budget;
  }

  Future<double> total(String userUID) async {
    double _total = 0;

    const path = '/expense/total';

    var body = Map<String, String>.from({"email": userUID});

    try {
      var jsonResponse = await _repository.execute(path: path, body: body);

      if (jsonResponse!['statusCode'] == 200) {
        if (jsonResponse.containsKey('total')) {
          _total = double.parse(jsonResponse['total'].toString());
        } else {
          _total = -1;
        }
      } else {
        // An internal server error ocurred
        throw Exception('Expense total method error: ${jsonResponse['error']}');
      }
    } catch (e) {
      print(e);
      _total = -3;
    }
    return _total;
  }

  Future<void> add(ExpenseModel expense) async {
    const path = '/expense/add';

    var body = Map<String, dynamic>.from({"email": expense.email, "value": expense.value});

    var jsonResponse = await _repository.execute(path: path, body: body);

    // Checking API Response Code
    if (jsonResponse!['statusCode'] == 200) {
    } else {
      // An internal server error ocurred
      throw Exception('Expense add method error: ${jsonResponse['error']}');
    }
  }

  Stream<List<ExpenseModel>> list(String userUID) async* {
    List<ExpenseModel> expensesList = [];

    const path = '/expense/list';

    var body = Map<String, String>.from({"email": userUID});

    try {
      var jsonResponse = await _repository.execute(path: path, body: body);

      if (jsonResponse!['statusCode'] == 200) {
        var jsonItems = jsonResponse['items'];

        for (int i = 0; i < jsonItems.length; i++) {
          expensesList.add(ExpenseModel.fromJSON(jsonItems[i] as Map<String, dynamic>));
        }

        yield expensesList;
      } else {
        // An internal server error ocurred
        throw Exception('Expenses list method error: ${jsonResponse['error']}');
      }
    } catch (e) {
      print(e);
    }
  }

  Stream<ExpenseModel?> last(String userUID) async* {
    const path = '/expense/last';

    var body = Map<String, String>.from({"email": userUID});

    var jsonResponse = await _repository.execute(path: path, body: body);

    if (jsonResponse!['statusCode'] == 200) {
      var jsonItems = jsonResponse['items'];

      if (jsonItems.length > 0) {
        yield ExpenseModel.fromJSON(jsonItems[0] as Map<String, dynamic>);
      } else {
        yield null;
      }
    } else {
      // An internal server error ocurred
      throw Exception('Expense last method error: ${jsonResponse['error']}');
    }
  }
}

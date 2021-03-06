import 'package:flutter_aws/src/models/expense.dart';
import 'package:flutter_aws/src/models/user.dart';
import 'package:flutter_aws/src/resources/api.dart';
import 'package:flutter_aws/src/resources/cognito.dart';
import 'package:flutter_aws/src/resources/expense.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Repository {
  static final _authResources = CognitoResources();
  static final _expenseResources = ExpenseResources();
  static final _apiResources = APIResources();

  // API Resources
  Future<Map<String, dynamic>?> execute({required String path, required Map<String, dynamic> body}) =>
      _apiResources.execute(path: path, body: body);

  // AWS Cognito Authentication Resources
  Future<User?> init() => _authResources.init();

  Future<User?> getCurrentUser() => _authResources.getCurrentUser();

  Future<int?> loginWithEmailAndPassword(String email, String password) =>
      _authResources.loginWithEmailAndPassword(email, password);

  Future<User?> signUpWithEmailAndPassword(String email, String password, String displayName) =>
      _authResources.signUpWithEmailAndPassword(email, password, displayName);

  Future<bool> confirmAccount(String email, String confirmationCode) =>
      _authResources.confirmAccount(email, confirmationCode);

  Future<void> resendConfirmationCode(String email) => resendConfirmationCode(email);

  Future<void> signOut() => _authResources.signOut();

  Future<String?> getUserUID() => _authResources.getUserUID();

  // AWS DynamoDB Expense Resources
  Future<double> setUserBudget(SharedPreferences prefs, double? budget) =>
      _expenseResources.setUserBudget(prefs, budget!);

  Future<double> totalSpent(String userUID) => _expenseResources.totalSpent(userUID);

  double budget(String userUID) => _expenseResources.getUserBudget();

  Future<void> addNewExpense(ExpenseModel expense) => _expenseResources.add(expense);

  Stream<List<ExpenseModel>> expensesList(String userUID) => _expenseResources.list(userUID);

  Stream<ExpenseModel?> lastExpense(String userUID) => _expenseResources.last(userUID);
}

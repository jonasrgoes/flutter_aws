import 'package:flutter_aws/src/models/expense.dart';
import 'package:flutter_aws/src/models/finance.dart';
import 'package:flutter_aws/src/models/user.dart';
import 'package:flutter_aws/src/resources/api.dart';
import 'package:flutter_aws/src/resources/cognito.dart';
import 'package:flutter_aws/src/resources/expense.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Repository {
  static final _authResources = CognitoResources();
  static final _expenseResources = ExpenseResources();
  static final _apiResources = APIResources();

  // API RESOURCES
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
  Stream<FinanceModel> userFinanceDoc(String userUID) => _expenseResources.userFinanceDoc(userUID);

  Future<double> setUserBudget(SharedPreferences prefs, double? budget) =>
      _expenseResources.setUserBudget(prefs, budget!);

  // Stream<double> updateTotal(String userUID) => _expenseResources.total(userUID);

  Future<void> addNewExpense(ExpenseModel expense) => _expenseResources.add(expense);

  Stream<List<ExpenseModel>> expensesList(String userUID) => _expenseResources.list(userUID);

  Stream<ExpenseModel?> lastExpense(String userUID) => _expenseResources.last(userUID);
}

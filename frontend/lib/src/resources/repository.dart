import 'package:flutter_aws/src/models/expense.dart';
import 'package:flutter_aws/src/models/finance.dart';
import 'package:flutter_aws/src/models/user.dart';
import 'package:flutter_aws/src/resources/api.dart';
import 'package:flutter_aws/src/resources/cognito.dart';
import 'package:flutter_aws/src/resources/expense.dart';

class Repository {
  static final _authResources = CognitoResources();
  static final _userFinanceResources = ExpenseResources();
  static final _apiResources = APIResources();

  /// API RESOURCES
  Future<Map<String, dynamic>?> execute({required String path, required Map<String, dynamic> body}) =>
      _apiResources.execute(path: path, body: body);

  /// AWS COGNITO
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

  /// AWS DynamoDB
  Stream<FinanceModel> userFinanceDoc(String userUID) => _userFinanceResources.userFinanceDoc(userUID);

  Stream<double> setUserBudget(String userUID, double? budget) => _userFinanceResources.setUserBudget(userUID, budget!);

  Stream<double> updateTotal(String userUID) => _userFinanceResources.updateTotal(userUID);

  Future<void> addNewExpense(ExpenseModel expense) => _userFinanceResources.addNewExpense(expense);

  Stream<List<ExpenseModel>> expensesList(String userUID) => _userFinanceResources.expensesList(userUID);

  Stream<ExpenseModel> lastExpense(String userUID) => _userFinanceResources.lastExpense(userUID);
}

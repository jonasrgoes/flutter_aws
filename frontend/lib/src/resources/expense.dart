import 'dart:convert';
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:flutter_aws/src/models/expense.dart';
import 'package:flutter_aws/src/models/finance.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ExpenseResources {
  late String _apiId;
  late String _accessKey;
  late String _secretKey;
  late String _awsRegion;
  late String _endPoint;
  late String _host;
  late String _stage;

  final String _https = 'https://';

  ExpenseResources() {
    _apiId = dotenv.get('API_ID', fallback: 'Environment API_ID not loaded!');
    _accessKey = dotenv.get('ACCESS_KEY', fallback: 'Environment ACCESS_KEY not loaded!');
    _secretKey = dotenv.get('SECRET_KEY', fallback: 'Environment SECRET_KEY not loaded!');
    _awsRegion = dotenv.get('AWS_REGION', fallback: 'Environment AWS_REGION not loaded!');
    _stage = dotenv.get('STAGE', fallback: 'Environment STAGE not loaded!');

    _host = '$_apiId.execute-api.$_awsRegion.amazonaws.com';
    _endPoint = '$_https$_host';
  }

  Future<Map<String, dynamic>?> callAPI({required String path, required Map<String, dynamic> body}) async {
    final awsSigV4Client = AwsSigV4Client(_accessKey, _secretKey, _endPoint, region: _awsRegion);

    var headers = {"Content-Type": "application/json; charset=utf-8", "Accept": "application/json"};

    SigV4Request? signedRequest;

    try {
      signedRequest = SigV4Request(awsSigV4Client, method: 'POST', path: '/$_stage$path', headers: headers, body: body);
    } catch (e) {
      print(e);
    }

    http.Response response;
    try {
      response = await http.post(
        Uri.parse(signedRequest!.url!),
        headers: Map.from(signedRequest.headers!),
        body: signedRequest.body,
      );
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonResponse;
      } else {
        // 'API call failed with status ${response.statusCode}'
        return {"statusCode": response.statusCode, "error": response.body};
      }
    } catch (e) {
      print(e);
      // throw HttpException('$e, statusCode: ${response.statusCode}, body: ${response.body}');
    }
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

    var jsonResponse = await callAPI(path: path, body: body);

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

    var jsonResponse = await callAPI(path: path, body: body);

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

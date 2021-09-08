import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';

class APIResources {
  late AwsSigV4Client _awsSigV4Client;

  late String _apiId;
  late String _accessKey;
  late String _secretKey;
  late String _awsRegion;
  late String _endPoint;
  late String _host;
  late String _stage;

  final String _https = 'https://';

  APIResources() {
    _apiId = dotenv.get('API_ID', fallback: 'Environment API_ID not loaded!');
    _accessKey = dotenv.get('ACCESS_KEY', fallback: 'Environment ACCESS_KEY not loaded!');
    _secretKey = dotenv.get('SECRET_KEY', fallback: 'Environment SECRET_KEY not loaded!');
    _awsRegion = dotenv.get('AWS_REGION', fallback: 'Environment AWS_REGION not loaded!');
    _stage = dotenv.get('STAGE', fallback: 'Environment STAGE not loaded!');

    _host = '$_apiId.execute-api.$_awsRegion.amazonaws.com';
    _endPoint = '$_https$_host';

    _awsSigV4Client = AwsSigV4Client(_accessKey, _secretKey, _endPoint, region: _awsRegion);
  }

  Future<Map<String, dynamic>?> execute({required String path, required Map<String, dynamic> body}) async {
    var headers = {"Content-Type": "application/json; charset=utf-8", "Accept": "application/json"};

    SigV4Request? signedRequest;

    try {
      signedRequest =
          SigV4Request(_awsSigV4Client, method: 'POST', path: '/$_stage$path', headers: headers, body: body);
    } catch (e) {
      print(e);
      rethrow;
    }

    http.Response response;
    try {
      response = await http.post(
        Uri.parse(signedRequest.url!),
        headers: Map.from(signedRequest.headers!),
        body: signedRequest.body,
      );
      print(response.body);
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
}

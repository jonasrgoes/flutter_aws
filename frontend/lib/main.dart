import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_aws/src/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // flutter_dotenv: loading environment variables...
  await dotenv.load(fileName: "assets/.env", mergeWith: Platform.environment);

  print('Env map: ${dotenv.env.toString()}');

  runApp(const FlutterAWS());
}

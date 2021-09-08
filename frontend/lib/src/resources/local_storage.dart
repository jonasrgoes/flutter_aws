import 'dart:convert';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Extend CognitoStorage with Shared Preferences to persist account
/// login sessions
class LocalStorage extends CognitoStorage {
  final SharedPreferences _prefs;
  LocalStorage(this._prefs);

  @override
  Future getItem(String key) async {
    String item;
    try {
      var _key = _prefs.getString(key);
      if (_key != null) {
        item = json.decode(_key);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
    return item;
  }

  @override
  Future setItem(String key, value) async {
    await _prefs.setString(key, json.encode(value));
    return getItem(key);
  }

  @override
  Future removeItem(String key) async {
    if (_prefs.containsKey(key)) {
      await _prefs.remove(key);
      return true;
    }
    return false;
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}

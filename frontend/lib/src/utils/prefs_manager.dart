import 'package:shared_preferences/shared_preferences.dart';

class PrefsManager {
  static const String prefUserDisplayName = "USER_DISPLAY_NAME";
  static const String prefUserBudget = "USER_DISPLAY_NAME";

  void setCurrentUserDisplayName(SharedPreferences prefs, String displayName) async {
    await prefs.setString(prefUserDisplayName, displayName);
  }

  String? getCurrentUserDisplayName(SharedPreferences prefs) {
    return prefs.getString(prefUserDisplayName);
  }

  void setUserBudget(SharedPreferences prefs, double budget) async {
    await prefs.setDouble(prefUserBudget, budget);
  }

  double? getUserBudget(SharedPreferences prefs) {
    return prefs.getDouble(prefUserBudget);
  }
}

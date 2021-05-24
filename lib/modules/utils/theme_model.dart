import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

// https://stackoverflow.com/a/64185945/2472398
class ThemeModel with ChangeNotifier {
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  ThemeModel({ThemeMode mode = ThemeMode.light}) : _mode = mode;

  ThemeMode initMode() {
    SharedPreferences.getInstance().then((prefs) {
      var darkModePref = prefs.getBool(PREF_DARK_MODE) ?? true;
      _mode = darkModePref ? ThemeMode.dark : ThemeMode.light;
      notify();
    });
    return _mode;
  }

  ThemeMode toggleMode() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notify();
    return _mode;
  }

  void notify() {
    notifyListeners();
    SharedPreferences.getInstance().then(
        (prefs) => prefs.setBool(PREF_DARK_MODE, _mode == ThemeMode.dark));
  }
}

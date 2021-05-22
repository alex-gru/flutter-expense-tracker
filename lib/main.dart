import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_expense_tracker/modules/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'modules/main/home_widget.dart';
import 'modules/utils/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  debugPaintSizeEnabled = false;

  final prefs = await SharedPreferences.getInstance();
  bool darkMode = prefs.getBool(PREF_DARK_MODE) ?? true;

  runApp(ExpensesApp(darkMode));
}

class ExpensesApp extends StatefulWidget {
  final darkMode;

  ExpensesApp(this.darkMode);

  @override
  _ExpensesAppState createState() => _ExpensesAppState();
}

class _ExpensesAppState extends State<ExpensesApp> {
  @override
  Widget build(BuildContext context) {
    var title = 'Expense Tracker';
    return AppStateWidget(
      child: MaterialApp(
        title: title,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
        ),
        darkTheme: ThemeData(
          brightness: widget.darkMode ? Brightness.dark : Brightness.light,
        ),
        themeMode: widget.darkMode ? ThemeMode.dark : ThemeMode.light,
        home: HomeWidget(title: title),
      ),
    );
  }
}

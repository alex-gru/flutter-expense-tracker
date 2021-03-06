import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_expense_tracker/modules/main/home.dart';
import 'package:flutter_expense_tracker/modules/state/app_state.dart';
import 'package:flutter_expense_tracker/modules/utils/theme_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  String? email = dotenv.env['FIREBASE_AUTH_EMAIL'];
  String? password = dotenv.env['FIREBASE_AUTH_PASSWORD'];
  if (email == null || password == null) {
    throw Exception('Cannot initialize firebase - could not get auth credentials from .env file.');
  }
  await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  debugPaintSizeEnabled = false;
  runApp(ExpensesApp());
}

class ExpensesApp extends StatefulWidget {
  ExpensesApp();

  @override
  _ExpensesAppState createState() => _ExpensesAppState();
}

class _ExpensesAppState extends State<ExpensesApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    var title = 'Expense Tracker';
    return ChangeNotifierProvider<ThemeModel>(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(
        builder: (_, model, __) {
          return AppStateWidget(
              child: MaterialApp(
            title: title,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: model.mode,
            home: Home(title, model),
          ));
        },
      ),
    );
  }
}

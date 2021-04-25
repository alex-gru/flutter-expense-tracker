import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  debugPaintSizeEnabled = false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: MyHomePage(title: 'Household Expenses'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _val1 = 0;
  double _val2 = 0;
  List<Expense> _expenses = [];

  void _incrementCounter() {
    setState(() {
      _val1++;
      _val2++;
    });
  }

  @override
  void initState() {
    queryExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: queryExpenses)
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$_val1',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    Text(
                      "her",
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$_val2',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    Text(
                      "him",
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
              ],
            ),
            Divider(),
            Row(
              children: [_buildListView()],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  void queryExpenses() {
    _expenses.clear();
    Query query = FirebaseFirestore.instance.collection('expenses');
    query.orderBy('when', descending: true).get().then((querySnapshot) async {
      querySnapshot.docs.forEach((document) {
        var expense = Expense(
          document.get('origin'),
          document.get('value'),
          document.get('when'),
        );
        setState(() {
          _expenses.add(expense);
          log(expense.toString());
        });
      });
      _val1 = calcSum('her');
      _val2 = calcSum('him');
    });
  }

  double calcSum(origin) => _expenses.where((element) => element.origin == origin).map((element) => element.value).reduce((value, element) => value + element);

  Column _buildListView() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _expenses
            .map((expense) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      expense.origin,
                    ),
                    Text(
                      expense.value.toString(),
                    ),
                    Text(
                      expense.when.toDate().toString(),
                    ),
                  ],
                ))
            .toList());
  }
}

class Expense {
  String origin;
  double value;
  Timestamp when;

  Expense(String origin, double value, Timestamp when) {
    this.origin = origin;
    this.value = value;
    this.when = when;
  }

  @override
  String toString() {
    return 'Expense{origin: $origin, value: $value, when: $when}';
  }
}

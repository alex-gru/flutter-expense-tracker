import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
        primarySwatch: Colors.lightBlue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
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
  final formatter = NumberFormat("#,###.0#");
  double _val1 = 0;
  double _val2 = 0;
  int _share1 = 2;
  int _share2 = 2;

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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          niceAmount(_val1),
                          style: Theme.of(context).textTheme.headline4,
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
                          niceAmount(_val2),
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        Text(
                          "him",
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              flex: 6,
            ),
            Expanded(
                child: Container(
                    height: 20,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.purple,
                          ),
                          flex: _share1,
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.lightGreen,
                          ),
                          flex: _share2,
                        ),
                      ],
                    )),
                flex: 1),
            Expanded(
                child: Container(height: 400, child: _buildListView()),
                flex: 30),
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
      // total amounts, e.g. € 38.58, € 45.31
      _val1 = calcSum('her');
      _val2 = calcSum('him');
      // share of person1 on total amount, e.g. 0.4599
      final _share = _val1 / (_val1 + _val2);
      // compute "flex" values, e.g. 460, 540
      // will be used for relative sizing of the horizontal bar
      _share1 = (_share * 1000).round();
      _share2 = ((1 - _share) * 1000).round();
      log('\n_share=$_share\n_share1=$_share1\n_share2=$_share2');
    });
  }

  double calcSum(origin) => _expenses
      .where((element) => element.origin == origin)
      .map((element) => element.value)
      .reduce((value, element) => value + element);

  Widget _buildListView() {
    return ListView.builder(
        itemCount: _expenses.length,
        padding: EdgeInsets.all(4.0),
        itemBuilder: (context, i) {
          return Column(
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(child: Text(niceAmount(_expenses[i].value)), flex: 3,),
                    Expanded(child: Text(niceDate(_expenses[i].when.toDate())), flex: 2),
                  ],
                ),
                leading: Icon(
                  Icons.account_circle,
                  color: _expenses[i].origin == 'her'
                      ? Colors.purple
                      : Colors.lightGreen,
                ),
                trailing: Icon(Icons.remove_circle_outline_outlined, color: Color(
                    0xFF525252)),
              ),
              Divider()
            ],
          );
        });
  }

  String niceAmount(double amount) => '€ ${formatter.format(amount)}';

  String niceDate(DateTime dateTime) {
    // https://stackoverflow.com/a/54391552/2472398
    final monthDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (monthDay == today)
      return "today";
    else if (monthDay == yesterday)
      return "yesterday";
    else
      return '${monthDay.month}/${monthDay.day}';
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

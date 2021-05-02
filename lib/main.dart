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
                          "person1",
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
                          "person2",
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
                child: Container(
                    height: 400,
                    child: _expenses.isEmpty
                        ? Center(child: Text('Pretty empty here. Use the button to add expenses.'))
                        : _buildListView()),
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
          document.id,
          document.get('origin'),
          document.get('value'),
          document.get('when'),
          document.get('text'),
        );
        setState(() {
          _expenses.add(expense);
          log(expense.toString());
        });
      });
      // total amounts, e.g. € 38.58, € 45.31
      _val1 = calcSum('person1');
      _val2 = calcSum('person2');
      // share of person1 on total amount, e.g. 0.4599
      final _share = _expenses.isEmpty ? 0.5 : _val1 / (_val1 + _val2);
      // compute "flex" values, e.g. 460, 540
      // will be used for relative sizing of the horizontal bar
      _share1 = (_share * 1000).round();
      _share2 = ((1 - _share) * 1000).round();
      log('\n_share=$_share\n_share1=$_share1\n_share2=$_share2');
    });
  }

  double calcSum(origin) => _expenses.isEmpty
      ? 0.0
      : _expenses
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
                    Expanded(
                      child: Text(niceAmount(_expenses[i].value)),
                      flex: 3,
                    ),
                    Expanded(
                        child: Text(niceDate(_expenses[i].when.toDate())),
                        flex: 2),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Text(
                      _expenses[i].text.isNotEmpty ? _expenses[i].text : ''),
                ),
                leading: Icon(
                  Icons.account_circle,
                  color: getPersonColor(_expenses[i].origin),
                ),
                trailing: IconButton(
                    icon: new Icon(Icons.remove_circle_outline_outlined,
                        color: Color(0xFF525252)),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                title: const Text('Delete Entry?'),
                                content: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_circle,
                                      color:
                                          getPersonColor(_expenses[i].origin),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                      child: Text(
                                        '${niceAmount(_expenses[i].value)}',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        FirebaseFirestore.instance
                                            .collection('expenses')
                                            .doc(_expenses[i].id)
                                            .delete()
                                            .catchError((e) => log(
                                                'Could not delete entry from Firebase collection. '
                                                'id: ${_expenses[i].id}, origin: ${_expenses[i].origin}, amount: ${_expenses[i].value}'));
                                      });
                                    },
                                    child: Text('Delete'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cancel'),
                                  )
                                ],
                              ));
                    }),
              ),
              Divider()
            ],
          );
        });
  }

  MaterialColor getPersonColor(String person) {
    return person == 'person1' ? Colors.purple : Colors.lightGreen;
  }

  String niceAmount(double amount) =>
      amount == 0 ? '-' : '€ ${formatter.format(amount)}';

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
  String id;
  String origin;
  double value;
  Timestamp when;
  String text;

  Expense(String id, String origin, double value, Timestamp when, String text) {
    this.id = id;
    this.origin = origin;
    this.value = value;
    this.when = when;
    this.text = text;
  }

  @override
  String toString() {
    return 'Expense{id: $id, origin: $origin, value: $value, when: $when, text: $text}';
  }
}

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_expense_tracker/modules/dialogs/add.dart';
import 'package:flutter_expense_tracker/modules/list_view.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'modules/dialog-result.dart';
import 'modules/expense.dart';
import 'modules/utils.dart';

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
                    Tooltip(
                      child: Column(
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
                      message:
                          'In total, person1 has spent ${niceAmount(_val1)}',
                    ),
                    Tooltip(
                      child: Column(
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
                      message:
                          'In total, person2 has spent ${niceAmount(_val2)}',
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
                        ? Center(
                            child: Text(
                                'Pretty empty here. Use the button to add expenses.',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w300)))
                        : ExpenseListView(
                            expenses: _expenses, callback: queryExpenses)),
                flex: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) => AddDialog())
              .then((value) {
            if (value == RESULT.ADDED) {
              queryExpenses();
            }
            return null;
          });
        },
        tooltip: 'Add Expense',
        child: Icon(Icons.add),
      ),
    );
  }

  void queryExpenses() {
    log('call: queryExpenses');
    Query query = FirebaseFirestore.instance.collection('expenses');
    query.orderBy('when', descending: true).get().then((querySnapshot) async {
      setState(() {
        _expenses.clear();
        querySnapshot.docs.forEach((document) {
          _expenses.add(Expense(
            document.id,
            document.get('origin'),
            document.get('value'),
            document.get('when'),
            document.get('text'),
          ));
        });
        // total amounts, e.g. € 38.58, € 45.31
        _val1 = calcSum('person1', _expenses);
        _val2 = calcSum('person2', _expenses);
        // share of person1 on total amount, e.g. 0.4599
        final _share = _expenses.isEmpty ? 0.5 : _val1 / (_val1 + _val2);
        // compute "flex" values, e.g. 460, 540
        // will be used for relative sizing of the horizontal bar
        _share1 = (_share * 1000).round();
        _share2 = ((1 - _share) * 1000).round();
        log('\n_share=$_share\n_share1=$_share1\n_share2=$_share2');
      });
    });
  }
}

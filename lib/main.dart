import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_expense_tracker/modules/dialogs/add.dart';
import 'package:flutter_expense_tracker/modules/list_view.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'modules/dialogs/dialog-result.dart';
import 'modules/expense.dart';
import 'modules/expense_balance.dart';
import 'modules/relative-balance.dart';
import 'modules/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  debugPaintSizeEnabled = false;
  runApp(ExpensesApp());
}

class ExpensesApp extends StatelessWidget {
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
      home: ExpensesHome(title: 'Household Expenses'),
    );
  }
}

class ExpensesHome extends StatefulWidget {
  final String title;

  ExpensesHome({Key key, this.title}) : super(key: key);

  @override
  _ExpensesHomeState createState() => _ExpensesHomeState();
}

class _ExpensesHomeState extends State<ExpensesHome> {
  double _val0 = 0;
  double _val1 = 0;
  int _share1 = 2;
  int _share2 = 2;

  List<Expense> _expenses = [];
  List<String> _persons = ["Person 1", "Person 2"];

  @override
  void initState() {
    queryPersons().then((value) => queryExpenses());
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
                    ExpenseBalance(balance: _val0, person: _persons.elementAt(0)),
                    ExpenseBalance(balance: _val1, person: _persons.elementAt(1)),
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
                        RelativeBalance(share: _share1, person: _persons.elementAt(0), persons: _persons),
                        RelativeBalance(share: _share2, person: _persons.elementAt(1), persons: _persons),
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
                            expenses: _expenses, callback: queryExpenses, persons: _persons)),
                flex: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) => AddDialog(_persons))
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

  Future<void> queryExpenses() async {
    log('call: queryExpenses');
    Query query = FirebaseFirestore.instance.collection('expenses');
    query.orderBy('when', descending: true).get().then((querySnapshot) async {
      setState(() {
        _expenses.clear();
        querySnapshot.docs.forEach((document) {
          _expenses.add(Expense(
            document.id,
            document.get('person'),
            document.get('value'),
            document.get('when'),
            document.get('text'),
          ));
        });
        // total amounts, e.g. € 38.58, € 45.31
        _val0 = calcSum(_persons.elementAt(0), _expenses);
        _val1 = calcSum(_persons.elementAt(1), _expenses);
        // share of person1 on total amount, e.g. 0.4599
        final _share = _expenses.isEmpty ? 0.5 : _val0 / (_val0 + _val1);
        // compute "flex" values, e.g. 460, 540
        // will be used for relative sizing of the horizontal bar
        _share1 = (_share * 1000).round();
        _share2 = ((1 - _share) * 1000).round();
        log('\n_share=$_share\n_share1=$_share1\n_share2=$_share2');
      });
      return Future.value(() => {});
    });
  }

  Future<void> queryPersons() async {
    log('call: queryPersons');
    Query query = FirebaseFirestore.instance.collection('persons').limit(1);
    query.get().then((querySnapshot) async {
      setState(() {
        _persons.clear();
        var result = querySnapshot.docs.first;
        _persons.add(result.get('person1'));
        _persons.add(result.get('person2'));
      });
      return Future.value(() => {});
    });
  }
}

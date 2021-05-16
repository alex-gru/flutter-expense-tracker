import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/balance/relative_balance.dart';
import 'package:flutter_expense_tracker/modules/person.dart';
import 'package:flutter_expense_tracker/modules/utils.dart';
import 'package:flutter_expense_tracker/modules/balance/align.dart' as align;
import 'package:flutter_restart/flutter_restart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dialogs/add.dart';
import 'dialogs/dialog_result.dart';
import 'expense.dart';
import 'balance/total_balance.dart';
import 'list_view.dart';

class ExpensesHome extends StatefulWidget {
  final String title;

  ExpensesHome({Key key, this.title}) : super(key: key);

  @override
  _ExpensesHomeState createState() => _ExpensesHomeState();
}

class _ExpensesHomeState extends State<ExpensesHome> {
  List<Expense> _expenses = [];
  List<Person> _persons = [];
  bool _loading = true;

  @override
  void initState() {
    queryPersons().then((value) => queryExpenses());
  }

  @override
  Widget build(BuildContext context) {
    const double relativeBalanceBarHeight = 20;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Tooltip(
            message: 'Toggle Dark Mode',
            child: IconButton(icon: Icon(Icons.nightlight_round), onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              setState(() async {
                prefs.setBool(PREF_DARK_MODE, !(prefs.getBool(PREF_DARK_MODE) ?? false));
                await FlutterRestart.restartApp();
              });
            }),
          ),
          Tooltip(
              message: 'Refresh',
              child: IconButton(icon: Icon(Icons.refresh), onPressed: queryExpenses)),
        ],
      ),
      body: AnimatedOpacity(
        opacity: _loading ? 0.8 : 1,
        duration: Duration(milliseconds: 100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _persons.isEmpty ? [] : [
                      TotalBalance(person: _persons.elementAt(0), persons: _persons),
                      TotalBalance(person: _persons.elementAt(1), persons: _persons),
                    ],
                  ),
                ),
                flex: 6,
              ),
              Stack(alignment: AlignmentDirectional.center, children: [
                Container(
                    height: relativeBalanceBarHeight,
                    child: Row(
                      children: _persons.isEmpty ? [] : [
                        RelativeBalance(
                            person: _persons.elementAt(0),
                            persons: _persons,
                            alignPercentage: align.Align.START),
                        RelativeBalance(
                            person: _persons.elementAt(1),
                            persons: _persons,
                            alignPercentage: align.Align.END),
                      ],
                    )),
                Container(
                  width: 5,
                  height: relativeBalanceBarHeight + 10,
                  color: Theme.of(context).accentColor,
                )
              ]),
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

    setState(() {
      double width = MediaQuery.of(context).size.width;
      _loading = true;
      _persons.elementAt(0).progress = 0.5 * width;
      _persons.elementAt(1).progress = 0.5 * width;

    });

    Query query = FirebaseFirestore.instance.collection('expenses');
    return query
        .where('person', whereIn: _persons.map((e) => e.person).toList())
        .orderBy('when', descending: true).get().then((querySnapshot) async {
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
        calcBalance(_persons, _expenses, context);
        log('${_persons.toString()}');
        _loading = false;
      });
    });
  }

  Future<void> queryPersons() async {
    log('call: queryPersons');
    Query query = FirebaseFirestore.instance.collection('persons').limit(1);
    return query.get().then((querySnapshot) async {
      setState(() {
        _persons.clear();
        var result = querySnapshot.docs.first;
        _persons.add(Person.create(result.get('person1')));
        _persons.add(Person.create(result.get('person2')));
      });
    });
  }

}

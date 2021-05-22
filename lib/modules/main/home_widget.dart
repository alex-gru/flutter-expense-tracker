import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/dto/person.dart';
import 'package:flutter_expense_tracker/modules/state/app_state.dart';
import 'package:flutter_expense_tracker/modules/utils/utils.dart';
import 'package:flutter_restart/flutter_restart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dialogs/add.dart';
import '../dialogs/dialog_result.dart';
import '../dto/expense.dart';
import 'balance_widget.dart';
import 'expenses_list_widget.dart';

class HomeWidget extends StatefulWidget {
  final String title;

  HomeWidget({Key key, this.title}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    queryPersons().then((persons) => queryExpenses(persons, true));
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
            child: IconButton(
                icon: Icon(Icons.nightlight_round),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  setState(() async {
                    prefs.setBool(PREF_DARK_MODE,
                        !(prefs.getBool(PREF_DARK_MODE) ?? false));
                    await FlutterRestart.restartApp();
                  });
                }),
          ),
          Tooltip(
              message: 'Refresh',
              child: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () =>
                      queryExpenses(AppStateScope.of(context).persons, true))),
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
                  child: BalanceWidget(
                      relativeBalanceBarHeight: relativeBalanceBarHeight),
                  flex: 28),
              Expanded(
                  child: ExpensesListWidget(
                    callback: () =>
                        queryExpenses(AppStateScope.of(context).persons, false),
                  ),
                  flex: 72),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => AddDialog())
              .then((value) {
            if (value == RESULT.ADDED) {
              queryExpenses(AppStateScope.of(context).persons, false);
            }
            return null;
          });
        },
        tooltip: 'Add Expense',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> queryExpenses(
      List<Person> persons, bool animateFromCenter) async {
    log('call: queryExpenses');
    setState(() {
      _loading = true;
      if (animateFromCenter) {
        double width = MediaQuery.of(context).size.width;
        persons.elementAt(0).progress = 0.5 * width;
        persons.elementAt(1).progress = 0.5 * width;
      }
    });

    Query query = FirebaseFirestore.instance.collection('expenses');
    return query
        .where('person', whereIn: persons.map((e) => e.person).toList())
        .orderBy('when', descending: true)
        .get()
        .then((querySnapshot) async {
      setState(() {
        List<Expense> expenses = [];
        querySnapshot.docs.forEach((document) {
          expenses.add(Expense(
            document.id,
            document.get('person'),
            document.get('value'),
            document.get('when'),
            document.get('text'),
          ));
        });
        List<Person> personsWithBalances =
            calcBalance(persons, expenses, context);
        AppStateWidget.of(context).setPersons(personsWithBalances);
        AppStateWidget.of(context).setExpenses(expenses);
        log('${persons.toString()}');
        _loading = false;
      });
    });
  }

  Future<List<Person>> queryPersons() async {
    log('call: queryPersons');
    Query query = FirebaseFirestore.instance.collection('persons').limit(1);
    return query.get().then((querySnapshot) async {
      List<Person> persons = [];
      var result = querySnapshot.docs.first;
      persons.add(Person.create(result.get('person1')));
      persons.add(Person.create(result.get('person2')));
      return persons;
    });
  }
}

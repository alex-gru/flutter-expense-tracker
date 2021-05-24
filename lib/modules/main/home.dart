import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/dialogs/add.dart';
import 'package:flutter_expense_tracker/modules/dialogs/dialog_result.dart';
import 'package:flutter_expense_tracker/modules/state/app_state.dart';
import 'package:flutter_expense_tracker/modules/utils/theme_model.dart';

import '../utils/utils.dart';
import 'balance_widget.dart';
import 'expenses_list_widget.dart';

class Home extends StatefulWidget {
  final String _title;
  final ThemeModel _model;

  const Home(this._title, this._model) : super();

  @override
  _HomeState createState() => _HomeState(_title, _model);
}

class _HomeState extends State<Home> {
  bool _loading = true;
  final String _title;
  final ThemeModel _model;

  _HomeState(this._title, this._model);

  @override
  void initState() {
    super.initState();
    _model.initMode();
    queryPersons().then((persons) => queryExpenses(persons, true, context));
  }

  @override
  Widget build(BuildContext context) {
    double relativeBalanceBarHeight = 20;
    log('build home');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(_title),
        actions: [
          Tooltip(
              message: 'Toggle Dark Mode',
              child: IconButton(
                icon: Icon(Icons.nightlight_round),
                onPressed: () => _model.toggleMode(),
              )),
          Tooltip(
              message: 'Refresh',
              child: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => queryExpenses(
                      AppStateScope.of(context).persons, true, context))),
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
                  child: BalanceWidget(relativeBalanceBarHeight), flex: 28),
              Expanded(
                  child: ExpensesListWidget(
                    () => queryExpenses(
                        AppStateScope.of(context).persons, false, context),
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
              queryExpenses(AppStateScope.of(context).persons, false, context);
            }
            return null;
          });
        },
        tooltip: 'Add Expense',
        child: Icon(Icons.add),
      ),
    );
  }
}

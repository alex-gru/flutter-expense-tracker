import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/dialogs/add.dart';
import 'package:flutter_expense_tracker/modules/dialogs/dialog_result.dart';
import 'package:flutter_expense_tracker/modules/dialogs/setup.dart';
import 'package:flutter_expense_tracker/modules/dialogs/share.dart';
import 'package:flutter_expense_tracker/modules/state/app_state.dart';
import 'package:flutter_expense_tracker/modules/utils/theme_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    SharedPreferences.getInstance().then((prefs) {
      var listId = prefs.getString(PREF_LIST_ID);
      if (listId == null) {
        log('no listId available yet!');
        showSetupDialog(prefs);
      } else {
        queryPersons(listId)
            .then((persons) => queryExpenses(persons, true, context));
      }
    });
  }

  void showSetupDialog(SharedPreferences prefs) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => SetupDialog()).then((value) {
      if (value == null || value == RESULT.CANCEL) {
        log('setup dialog cancelled.');
        showSetupDialog(prefs);
      } else {
        log('new list created successfully: $value');
        prefs.setString(PREF_LIST_ID, value).then((listId) =>
            queryPersons(value)
                .then((persons) => queryExpenses(persons, true, context)));
      }
    });
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
              message: 'Share',
              child: IconButton(
                  icon: Icon(Icons.group),
                  onPressed: () => handleShare(context))),
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

  Future<Set<Future<dynamic>>> handleShare(BuildContext context) async {
    return {
      SharedPreferences.getInstance().then((prefs) {
        var listId = prefs.getString(PREF_LIST_ID);
        showDialog(context: context, builder: (_) => ShareDialog(listId))
            .then((value) async {
          if (value == RESULT.LEAVE_LIST) {
            log('leave list now.');
            prefs.remove(PREF_LIST_ID);
            prefs.remove(PREF_PERSON);
            AppStateWidget.of(context).setPersons([]);
            AppStateWidget.of(context).setExpenses([]);
            showSetupDialog(prefs);
          } else if (value != null && value != RESULT.CANCEL) {
            final persons = await queryPersons(value);
            final msg;
            if (persons.isEmpty) {
              msg = 'Could not find a list for the provided code.';
            } else {
              msg = 'Successfully joined the list.';
              prefs.setString(PREF_LIST_ID, value);
              queryExpenses(persons, true, context);
            }
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(msg),
            ));
          }
        });
      })
    };
  }
}

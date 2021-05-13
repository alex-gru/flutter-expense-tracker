import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/utils.dart';

import 'dialogs/delete.dart';
import 'dialogs/dialog-result.dart';
import 'expense.dart';

class ExpenseListView extends StatefulWidget {
  final List<Expense> expenses;
  final List<String> persons;
  final void Function() callback;

  ExpenseListView({List<Expense> expenses, Function callback, List<String> persons}) : this.expenses = expenses, this.callback = callback, this.persons = persons;

  @override
  _ExpenseListViewState createState() => new _ExpenseListViewState(expenses, persons);
}

class _ExpenseListViewState extends State<ExpenseListView> {
  final List<Expense> expenses;
  final List<String> persons;

  _ExpenseListViewState(List<Expense> expenses, List<String> persons) : this.expenses = expenses, this.persons = persons;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: expenses.length,
        padding: EdgeInsets.all(4.0),
        itemBuilder: (context, i) {
          return Column(
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(niceAmount(expenses[i].value)),
                      flex: 3,
                    ),
                    Expanded(
                        child: Tooltip(
                          child: Text(niceDate(expenses[i].when)),
                          message: shortDate(expenses[i].when),
                        ),
                        flex: 2),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Text(expenses[i].text),
                ),
                leading: Tooltip(
                  child: Icon(
                    Icons.account_circle,
                    color: getPersonColor(expenses[i].person, persons),
                  ),
                  message: expenses[i].person,
                ),
                trailing: Tooltip(
                  child: IconButton(
                      icon: new Icon(Icons.remove_circle_outline_outlined,
                          color: Color(0xFF525252)),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) => DeleteDialog(
                                expense: expenses[i],
                                persons: persons
                                )).then((value) {
                          if (value == RESULT.DELETED) {
                            this.widget.callback();
                          }
                          return null;
                        });
                      }),
                  message: 'Delete',
                ),
              ),
              Divider()
            ],
          );
        });
  }
}

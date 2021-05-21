import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/person.dart';
import 'package:flutter_expense_tracker/modules/utils.dart';

import 'dialogs/delete.dart';
import 'dialogs/dialog_result.dart';
import 'expense.dart';

class ExpenseListView extends StatefulWidget {
  final List<Expense> expenses;
  final List<Person> persons;
  final void Function() callback;

  ExpenseListView(
      {List<Expense> expenses, Function callback, List<Person> persons})
      : this.expenses = expenses,
        this.callback = callback,
        this.persons = persons;

  @override
  _ExpenseListViewState createState() =>
      new _ExpenseListViewState(expenses, persons);
}

class _ExpenseListViewState extends State<ExpenseListView> {
  final List<Expense> expenses;
  final List<Person> persons;

  _ExpenseListViewState(List<Expense> expenses, List<Person> persons)
      : this.expenses = expenses,
        this.persons = persons;

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Tooltip(
                        child: Icon(
                          Icons.account_circle,
                          color: getPersonColor(expenses[i].person, persons),
                        ),
                        message: expenses[i].person,
                      ),
                      flex: 1
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prettifyAmount(expenses[i].value),
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                              child: Text(
                                expenses[i].text,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          ],
                        ),
                      ),
                      flex: 4,
                    ),
                    Expanded(
                        child: Tooltip(
                          child: Text(
                            niceDate(expenses[i].when),
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                          message: shortDate(expenses[i].when),
                        ),
                        flex: 2),
                    Expanded(
                      child: Tooltip(
                        child: IconButton(
                            icon: new Icon(Icons.remove_circle_outline_outlined,
                                color: Color(0xFF525252)),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (_) => DeleteDialog(
                                      expense: expenses[i],
                                      persons: persons)).then((value) {
                                if (value == RESULT.DELETED) {
                                  this.widget.callback();
                                }
                                return null;
                              });
                            }),
                        message: 'Delete',
                      ),
                      flex: 1
                    )
                  ],
                ),
              ),
              Divider()
            ],
          );
        });
  }
}

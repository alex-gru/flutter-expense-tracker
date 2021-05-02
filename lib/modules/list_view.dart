import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/utils.dart';

import 'delete.dart';
import 'expense.dart';

class ExpenseListView extends StatefulWidget {
  final List<Expense> expenses;
  final void Function() callback;

  ExpenseListView({this.expenses, this.callback});

  @override
  _ExpenseListViewState createState() => new _ExpenseListViewState(expenses);
}

class _ExpenseListViewState extends State<ExpenseListView> {
  final List<Expense> expenses;

  _ExpenseListViewState(this.expenses);

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
                        child: Text(niceDate(expenses[i].when.toDate())),
                        flex: 2),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child:
                      Text(expenses[i].text.isNotEmpty ? expenses[i].text : ''),
                ),
                leading: Icon(
                  Icons.account_circle,
                  color: getPersonColor(expenses[i].origin),
                ),
                trailing: IconButton(
                    icon: new Icon(Icons.remove_circle_outline_outlined,
                        color: Color(0xFF525252)),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) => DeleteDialog(
                                expense: expenses[i],
                              )).then((value) {
                        if (value == RESULT.DELETE) {
                          this.widget.callback();
                        }
                        return null;
                      });
                    }),
              ),
              Divider()
            ],
          );
        });
  }
}

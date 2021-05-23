import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/state/app_state.dart';
import 'package:flutter_expense_tracker/modules/utils/utils.dart';

import '../dialogs/delete.dart';
import '../dialogs/dialog_result.dart';

class ExpenseListView extends StatefulWidget {
  final void Function() callback;

  ExpenseListView({Function callback}) : this.callback = callback;

  @override
  _ExpenseListViewState createState() => new _ExpenseListViewState();
}

class _ExpenseListViewState extends State<ExpenseListView> {
  _ExpenseListViewState() : super();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: AppStateScope.of(context).expenses.length,
        padding: EdgeInsets.all(0),
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
                            color: getPersonColor(
                                AppStateScope.of(context).expenses[i].person,
                                context),
                          ),
                          message: AppStateScope.of(context).expenses[i].person,
                        ),
                        flex: 1),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prettifyAmount(
                                  AppStateScope.of(context).expenses[i].value),
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                              child: Text(
                                AppStateScope.of(context).expenses[i].text,
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
                            niceDate(
                                AppStateScope.of(context).expenses[i].when),
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                          message: shortDate(
                              AppStateScope.of(context).expenses[i].when),
                        ),
                        flex: 2),
                    Expanded(
                        child: Tooltip(
                          child: IconButton(
                              icon: new Icon(
                                  Icons.remove_circle_outline_outlined,
                                  color: Color(0xFF525252)),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (_) => DeleteDialog(
                                        expense: AppStateScope.of(context)
                                            .expenses[i])).then((value) {
                                  if (value == RESULT.DELETED) {
                                    this.widget.callback();
                                  }
                                  return null;
                                });
                              }),
                          message: 'Delete',
                        ),
                        flex: 1)
                  ],
                ),
              ),
              Divider()
            ],
          );
        });
  }
}

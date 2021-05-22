import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/state/app_state.dart';

import '../utils/list_view.dart';

class ExpensesListWidget extends StatelessWidget {
  final void Function() _callback;

  const ExpensesListWidget({
    Key key,
    Function callback,
  })  : _callback = callback,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppStateScope.of(context).expenses.isEmpty
        ? Center(
            child: Text('Pretty empty here. Use the button to add expenses.',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w300)))
        : ExpenseListView(callback: _callback);
  }
}

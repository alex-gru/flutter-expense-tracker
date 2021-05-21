import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/dto/person.dart';

import '../dto/expense.dart';
import '../utils/list_view.dart';

class ExpensesListWidget extends StatelessWidget {

  final List<Expense> _expenses;
  final List<Person> _persons;
  final void Function() _callback;

  const ExpensesListWidget({
    Key key, List<Expense> expenses, Function callback, List<Person> persons,
  }) : _expenses = expenses,
        _persons = persons,
        _callback = callback,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return _expenses.isEmpty
        ? Center(
        child: Text(
            'Pretty empty here. Use the button to add expenses.',
            style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w300)))
        : ExpenseListView(
        expenses: _expenses,
        callback: _callback,
        persons: _persons);
  }
}
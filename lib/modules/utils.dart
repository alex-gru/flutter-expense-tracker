import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/expense.dart';
import 'package:flutter_expense_tracker/modules/person.dart';
import 'package:intl/intl.dart';

final amountFormatter = NumberFormat("#,###.00#");
final shareFormatter = NumberFormat("##.0#");
final dateTimeFormatter = DateFormat('yyyy-MM-dd kk:mm');

MaterialColor getPersonColor(String person, List<Person> persons) {
  return persons.indexWhere((p) => p.person == person) == 0 ? Colors.purple : Colors.lightGreen;
}

String prettifyAmount(double amount) =>
    amount == 0 ? '€ 0' : '€ ${amountFormatter.format(amount)}';

String prettifyShare(double share) =>
    share == 0 ? '' : '${shareFormatter.format(share*100)}%';

String niceDate(Timestamp timestamp) {
  // https://stackoverflow.com/a/54391552/2472398
  final dateTime = timestamp.toDate();
  final shortDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);

  if (shortDate == today)
    return "today";
  else if (shortDate == yesterday)
    return "yesterday";
  else
    return '${shortDate.month}/${shortDate.day}';
}

String shortDate(Timestamp timestamp) {
  final dateTime = timestamp.toDate();
  return dateTimeFormatter.format(dateTime);
}

double calcSum(person, expenses) {
  var expensesForPerson = expenses.where((element) => element.person == person);
  return expensesForPerson.isEmpty
      ? 0.0
      : expensesForPerson
          .map((element) => element.value)
          .reduce((value, element) => value + element);
}

void calcBalance(List<Person> persons, List<Expense> expenses) {
  var _person0 = persons.elementAt(0).person;
  var _person1 = persons.elementAt(1).person;

  // total amounts, e.g. € 38.58, € 45.31
  var _sum0 = calcSum(_person0, expenses);
  var _sum1 = calcSum(_person1, expenses);

  // share of person1 on total amount, e.g. 0.4599
  var _share0 = expenses.isEmpty ? 0.5 : _sum0 / (_sum0 + _sum1);
  var _share1 = 1 - _share0;

  // "flex" values are used for sizing of the relative balance bar (e.g. 460, 540)
  var _flex0 = (_share0 * 1000).round();
  var _flex1 = (_share1 * 1000).round();

  persons.clear();
  persons.add(Person(_person0, _sum0, _share0, _flex0));
  persons.add(Person(_person1, _sum1, _share1, _flex1));
}

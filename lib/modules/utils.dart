import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final formatter = NumberFormat("#,###.0#");

MaterialColor getPersonColor(String person) {
  return person == 'person1' ? Colors.purple : Colors.lightGreen;
}

String niceAmount(double amount) =>
    amount == 0 ? '-' : '€ ${formatter.format(amount)}';

String niceDate(DateTime dateTime) {
  // https://stackoverflow.com/a/54391552/2472398
  final monthDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);

  if (monthDay == today)
    return "today";
  else if (monthDay == yesterday)
    return "yesterday";
  else
    return '${monthDay.month}/${monthDay.day}';
}

double calcSum(origin, expenses) => expenses.isEmpty
    ? 0.0
    : expenses
        .where((element) => element.origin == origin)
        .map((element) => element.value)
        .reduce((value, element) => value + element);

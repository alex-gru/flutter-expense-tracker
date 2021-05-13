import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final amountFormatter = NumberFormat("#,###.0#");
final dateTimeFormatter = DateFormat('yyyy-MM-dd kk:mm');

MaterialColor getPersonColor(String person, List<String> persons) {
  return persons.indexOf(person) == 0 ? Colors.purple : Colors.lightGreen;
}

String niceAmount(double amount) =>
    amount == 0 ? '€ 0' : '€ ${amountFormatter.format(amount)}';

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

double calcSum(origin, expenses) {
  var expensesForOrigin = expenses.where((element) => element.origin == origin);
  return expensesForOrigin.isEmpty
      ? 0.0
      : expensesForOrigin
          .map((element) => element.value)
          .reduce((value, element) => value + element);
}

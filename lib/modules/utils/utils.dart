import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/dto/expense.dart';
import 'package:flutter_expense_tracker/modules/dto/person.dart';
import 'package:flutter_expense_tracker/modules/state/app_state.dart';
import 'package:intl/intl.dart';

final amountFormatter = NumberFormat("#,###.0#");
final shareFormatter = NumberFormat("##.0#");
final dateTimeFormatter = DateFormat('yyyy-MM-dd HH:mm');
const PREF_ACCOUNT_ID = 'accountId';
const PREF_DARK_MODE = 'darkMode';
const PREF_PERSON = 'selectedPerson';

Color getPersonColor(String person, BuildContext context) {
  return AppStateScope.of(context)
              .persons
              .indexWhere((p) => p.person == person) ==
          0
      ? Colors.green.shade600
      : Colors.orange.shade800;
}

String prettifyAmount(double amount) =>
    '€ ${prettifyAmountWithoutCurrency(amount)}';

String prettifyAmountWithoutCurrency(double amount) =>
    amount == 0 ? '0' : '${amountFormatter.format(amount)}';

String prettifyShare(double share) =>
    share == 0 ? ' 0.0%' : ' ${shareFormatter.format(share * 100)}% ';

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

double calcSum(person, List<Expense> expenses) {
  var expensesForPerson = expenses.where((element) => element.person == person);
  return expensesForPerson.isEmpty
      ? 0.0
      : expensesForPerson
          .map((element) => element.value)
          .reduce((value, element) => value + element);
}

List<Person> calcBalance(
    List<Person> persons, List<Expense> expenses, BuildContext context) {
  var person0 = persons.elementAt(0).person;
  var person1 = persons.elementAt(1).person;

  // total amounts, e.g. € 38.58, € 45.31
  var sum0 = calcSum(person0, expenses);
  var sum1 = calcSum(person1, expenses);

  // share of person1 on total amount, e.g. 0.4599
  var share0 = expenses.isEmpty ? 0.5 : sum0 / (sum0 + sum1);
  var share1 = 1 - share0;

  // "progress" values are used for sizing of the relative balance bar
  double width = MediaQuery.of(context).size.width;
  var progress0 = share0 * width;
  var progress1 = share1 * width;

  return [
    Person(person0, sum0, share0, progress0),
    Person(person1, sum1, share1, progress1)
  ];
}

Future<void> queryExpenses(
    List<Person> persons, bool animateFromCenter, BuildContext context) async {
  log('call: queryExpenses');
  // _loading = true;
  if (animateFromCenter) {
    double width = MediaQuery.of(context).size.width;
    persons.elementAt(0).progress = 0.5 * width;
    persons.elementAt(1).progress = 0.5 * width;
  }
  Query query = FirebaseFirestore.instance.collection('expenses');
  return query
      .where('person', whereIn: persons.map((e) => e.person).toList())
      .orderBy('when', descending: true)
      .get()
      .then((querySnapshot) async {
    List<Expense> expenses = [];
    querySnapshot.docs.forEach((document) {
      expenses.add(Expense(
        document.id,
        document.get('person'),
        document.get('value'),
        document.get('when'),
        document.get('text'),
      ));
    });
    List<Person> personsWithBalances = calcBalance(persons, expenses, context);
    AppStateWidget.of(context).setPersons(personsWithBalances);
    AppStateWidget.of(context).setExpenses(expenses);
    log('${personsWithBalances.toString()}');
    // _loading = false;
  });
}

Future<List<Person>> queryPersons(String accountId) async {
  log('call: queryPersons');
  DocumentReference query = FirebaseFirestore.instance.collection('persons').doc(accountId);
  return query.get().then((account) async {
    List<Person> persons = [];
    persons.add(Person.create(account.get('person1')));
    persons.add(Person.create(account.get('person2')));
    return persons;
  });
}

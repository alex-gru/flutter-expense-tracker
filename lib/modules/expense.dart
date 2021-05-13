import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String id;
  String person;
  double value;
  Timestamp when;
  String text;

  Expense(String id, String person, double value, Timestamp when, String text) {
    this.id = id;
    this.person = person;
    this.value = value;
    this.when = when;
    this.text = text;
  }

  @override
  String toString() {
    return 'Expense{id: $id, person: $person, value: $value, when: $when, text: $text}';
  }

  static create(String person, double amount, Timestamp timestamp, String text) {
    return Expense('placeholderId', person, amount, timestamp, text);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String person;
  final double value;
  final Timestamp when;
  final String text;

  Expense(this.id, this.person, this.value, this.when, this.text);

  @override
  String toString() {
    return 'Expense{id: $id, person: $person, value: $value, when: $when, text: $text}';
  }

  static create(
      String person, double amount, Timestamp timestamp, String text) {
    return Expense('placeholderId', person, amount, timestamp, text);
  }
}

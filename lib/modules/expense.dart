import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String id;
  String origin;
  double value;
  Timestamp when;
  String text;

  Expense(String id, String origin, double value, Timestamp when, String text) {
    this.id = id;
    this.origin = origin;
    this.value = value;
    this.when = when;
    this.text = text;
  }

  @override
  String toString() {
    return 'Expense{id: $id, origin: $origin, value: $value, when: $when, text: $text}';
  }
}

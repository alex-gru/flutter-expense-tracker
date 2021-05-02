import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../dialog-result.dart';
import '../expense.dart';
import '../utils.dart';

class DeleteDialog extends StatefulWidget {
  final Expense expense;

  DeleteDialog({Expense expense}) : this.expense = expense;

  @override
  _DeleteDialogState createState() => new _DeleteDialogState(expense);
}

class _DeleteDialogState extends State<DeleteDialog> {
  final Expense expense;

  _DeleteDialogState(this.expense);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete this Expense?'),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 0, 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Icon(
                Icons.account_circle,
                color: getPersonColor(expense.origin),
              ),
              flex: 1,
            ),
            Expanded(
              child: Text(
                '${niceAmount(expense.value)}',
              ),
              flex: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, RESULT.DELETED);
            FirebaseFirestore.instance
                .collection('expenses')
                .doc(expense.id)
                .delete()
                .catchError((e) => log(
                    'Could not delete entry from Firebase collection. '
                    'id: ${expense.id}, origin: ${expense.origin}, amount: ${expense.value}'));
          },
          child: Text('Delete'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, RESULT.CANCEL);
          },
          child: Text('Cancel'),
        )
      ],
    );
  }
}
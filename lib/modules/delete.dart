import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'expense.dart';
import 'utils.dart';

enum RESULT { DELETE, CANCEL }

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
      title: const Text('Delete Entry?'),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            color: getPersonColor(expense.origin),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Text(
              '${niceAmount(expense.value)}',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, RESULT.DELETE);
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

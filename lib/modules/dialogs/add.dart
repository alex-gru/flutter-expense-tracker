import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dialog-result.dart';
import '../expense.dart';
import '../utils.dart';

class AddDialog extends StatefulWidget {
  AddDialog() : super();

  @override
  _AddDialogState createState() => new _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  String _origin = 'person1';
  double _amount;
  String _text;

  _AddDialogState();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add new Expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: _origin,
                itemHeight: 62,
                icon: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: Icon(
                    Icons.account_circle,
                    color: getPersonColor(_origin),
                  ),
                ),
                onChanged: (String newValue) {
                  setState(() {
                    _origin = newValue;
                  });
                },
                items: <String>['person1', 'person2']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                    ),
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                child: ConstrainedBox(
                  child: TextField(
                    onChanged: (value) {
                      return _amount = double.parse(value);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'e.g. 23.94',
                    ),
                    inputFormatters: [
                      // https://stackoverflow.com/a/66919717/2472398
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        try {
                          final text = newValue.text;
                          if (text.isNotEmpty) double.parse(text);
                          return newValue;
                        } catch (e) {}
                        return oldValue;
                      }),
                    ],
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                  constraints: BoxConstraints.tight(Size(96, 62)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: ConstrainedBox(
              child: TextField(
                onChanged: (value) => _text = value,
                keyboardType: TextInputType.text,
                maxLines: null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Describe your purchase',
                ),
              ),
              constraints: BoxConstraints.tight(Size(200, 100)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            var _expense =
                Expense.create(_origin, _amount, Timestamp.now(), _text);
            FirebaseFirestore.instance
                .collection('expenses')
                .add({
                  'origin': _expense.origin,
                  'value': _expense.value,
                  'when': _expense.when,
                  'text': _expense.text
                })
                .then((value) => Navigator.pop(context, RESULT.ADDED))
                .catchError((e) => log(
                    'Could not add new expense to Firebase collection. '
                    'origin: ${_expense.origin}, amount: ${_expense.value}'));
          },
          child: Text('Add'),
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

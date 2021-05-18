import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../person.dart';
import 'dialog_result.dart';
import '../expense.dart';
import '../utils.dart';

class AddDialog extends StatefulWidget {
  final List<Person> persons;

  AddDialog(List<Person> persons) : this.persons = persons;

  @override
  _AddDialogState createState() => new _AddDialogState(persons);
}

class _AddDialogState extends State<AddDialog> {
  List<Person> persons = [];
  String _person;
  double _amount;
  String _text;

  _AddDialogState(List<Person> persons) : this.persons = persons;

  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((sharedPref) {
      setState(() {
        // choose previously selected person
        _person =
            sharedPref.getString(PREF_PERSON) ?? persons.elementAt(0).person;
      });
    });

    return AlertDialog(
      title: const Text('Add Expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: _person,
                itemHeight: 62,
                icon: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                ),
                onChanged: (String newValue) {
                  SharedPreferences.getInstance().then((sharedPref) =>
                      sharedPref.setString(PREF_PERSON, _person));
                  setState(() {
                    _person = newValue;
                  });
                },
                items: persons
                    .map((e) => e.person)
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: Icon(
                            Icons.account_circle,
                            color: getPersonColor(value, persons),
                          ),
                        ),
                        Text(
                          value,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                child: ConstrainedBox(
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _amount = double.tryParse(value)),
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
                onChanged: (value) => setState(() => _text = value),
                keyboardType: TextInputType.text,
                maxLines: null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Describe the expense',
                ),
              ),
              constraints: BoxConstraints.tight(Size(200, 100)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _amount == null || _text == null || _text.isEmpty
              ? null
              : () {
                  var _expense =
                      Expense.create(_person, _amount, Timestamp.now(), _text);
                  FirebaseFirestore.instance
                      .collection('expenses')
                      .add({
                        'person': _expense.person,
                        'value': _expense.value,
                        'when': _expense.when,
                        'text': _expense.text
                      })
                      .then((value) => Navigator.pop(context, RESULT.ADDED))
                      .catchError((e) => log(
                          'Could not add new expense to Firebase collection. ${_expense.toString()}'));
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

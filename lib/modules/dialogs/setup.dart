import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/share/qr_scanner.dart';

import 'dialog_result.dart';

class SetupDialog extends StatefulWidget {
  SetupDialog() : super();

  @override
  _SetupDialogState createState() => new _SetupDialogState();
}

class _SetupDialogState extends State<SetupDialog> {
  String? _person1;
  String? _person2;
  bool _showNewListForm = false;

  _SetupDialogState() : super();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: !_showNewListForm,
            child: Text(
              "Welcome!",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Visibility(
            visible: _showNewListForm,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Theme.of(context).accentColor),
                Text(
                  "Create new List",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 18, 0, 18),
            child: Text(
              "Expense Tracker helps you track household expenses.",
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          Visibility(
            visible: _showNewListForm,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Divider(),
                  ),
                  Text(
                    "To get started, provide the names of the household members.",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: !_showNewListForm,
            child: Column(
              children: [
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: StadiumBorder(),
                      side: BorderSide(
                          width: 1, color: Theme.of(context).accentColor),
                    ),
                    onPressed: () async {
                      log('Open QR Scanner...');
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QrScanner()),
                      );
                      log('QR code result: $result');
                      Navigator.pop(context, result ?? RESULT.CANCEL);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code,
                            color: Theme.of(context).accentColor),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                          child: Text(
                            "Join existing list",
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ],
                    )),
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: StadiumBorder(),
                      side: BorderSide(
                          width: 1, color: Theme.of(context).accentColor),
                    ),
                    onPressed: () async {
                      setState(() {
                        _showNewListForm = true;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Theme.of(context).accentColor),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                          child: Text(
                            "Create new list",
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
          Visibility(
            visible: _showNewListForm,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: TextField(
                    onChanged: (value) => setState(() => _person1 = value),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'e.g. Mary',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) => setState(() => _person2 = value),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'e.g. John',
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      actions: [
        Visibility(
          visible: _showNewListForm,
          child: TextButton(
            onPressed: () => {
              setState(() {
                _showNewListForm = false;
              })
            },
            child: Text('Go back'),
          ),
        ),
        Visibility(
          visible: _showNewListForm,
          child: TextButton(
            onPressed: _person1 == null ||
                    _person2 == null ||
                    _person1!.trim().isEmpty ||
                    _person2!.trim().isEmpty
                ? null
                : () {
                    FirebaseFirestore.instance
                        .collection('lists')
                        .add({
                          'person1': _person1,
                          'person2': _person2,
                        })
                        .then((value) => Navigator.pop(context, value.id))
                        .catchError((e) => log(
                            'Could not create new list in Firebase collection. $_person1, $_person2'));
                  },
            child: Text('Create list'),
          ),
        ),
        // TextButton(
        //   onPressed: () {
        //     Navigator.pop(context, RESULT.CANCEL);
        //   },
        //   child: Text('Cancel'),
        // )
      ],
    );
  }
}

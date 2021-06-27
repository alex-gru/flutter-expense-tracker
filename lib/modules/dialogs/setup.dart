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

  _SetupDialogState() : super();

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      // title: const Text('Create New List'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Let's get started",
            style: Theme.of(context).textTheme.headline6,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0,18,0,18),
            child: Text(
              "Expense Tracker makes tracking of household expenses easy.",
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: StadiumBorder(),
                side: BorderSide(width: 1, color: Theme.of(context).accentColor),
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
              child: Text(
                "Scan QR code to join list",
                style: Theme.of(context).textTheme.caption,
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(8,8,8,8),
            child: TextField(
              onChanged: (value) => setState(() => _person1 = value),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Household member 1',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => _person2 = value),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Household member 2',
              ),),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: _person1 == null || _person2 == null || _person1!.trim().isEmpty || _person2!.trim().isEmpty
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
          child: Text('Create List'),
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

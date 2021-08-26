import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/share/qr_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'dialog_result.dart';

class ShareDialog extends StatefulWidget {
  final String? _listId;

  ShareDialog(this._listId);

  @override
  _ShareDialogState createState() => new _ShareDialogState(_listId);
}

class _ShareDialogState extends State<ShareDialog> {
  final String? _listId;
  int _leaveCounter = 0;

  _ShareDialogState(this._listId);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Share List",
            style: Theme.of(context).textTheme.headline6,
          ),
          Divider(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 200,
                height: 200,
                child: QrImage(
                  data: _listId ?? '',
                  version: QrVersions.auto,
                  size: 200.0,
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.info_outline),
                  Container(
                    padding: const EdgeInsets.fromLTRB(4, 16, 0, 0),
                    width: 200,
                    child: Text(
                      "Open the Expense Tracker app on the other device and scan this QR code to join the shared list.",
                      style: Theme.of(context).textTheme.caption,
                    ),
                  )
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0,12,0,0),
            child: Column(
              children: [
                Divider(),
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: StadiumBorder(),
                      backgroundColor: _leaveCounter > 0 ? Colors.red : null,
                    ),
                    onPressed: () async {
                      if (_leaveCounter == 0) {
                        setState(() {
                          _leaveCounter++;
                        });
                      } else {
                        Navigator.pop(context, RESULT.LEAVE_LIST);
                      }
                    },
                    child: Text(
                      _leaveCounter > 0 ? "Are you sure? Tap again to leave." : "Leave list",
                      style: Theme.of(context).textTheme.caption,
                    )),
              ],
            ),
          ),

        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, RESULT.CANCEL);
          },
          child: Text('OK'),
        )
      ],
    );
  }
}

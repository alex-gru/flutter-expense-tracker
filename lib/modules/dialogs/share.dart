import 'dart:developer';

import 'package:flutter/material.dart';

import 'dialog_result.dart';

class ShareDialog extends StatefulWidget {
  final String _accountId;

  ShareDialog(this._accountId);

  @override
  _ShareDialogState createState() => new _ShareDialogState(_accountId);
}

class _ShareDialogState extends State<ShareDialog> {
  final String _accountId;

  _ShareDialogState(this._accountId);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // title: const Text('Setup'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: StadiumBorder(),
                side: BorderSide(width: 2, color: Theme.of(context).accentColor),
              ),
              onPressed: () => {log('Share now')},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4,0,0,0),
                    child: Text(
                      "Share",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                ],
              )),
          // Text(_accountId),
          Divider(),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: StadiumBorder(),
                side: BorderSide(width: 1, color: Theme.of(context).disabledColor),
              ),
              onPressed: () => {log('Leave this list now')},
              child: Text(
                "Leave this list",
                style: Theme.of(context).textTheme.caption,
              )),
        ],
      ),
      actions: [
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

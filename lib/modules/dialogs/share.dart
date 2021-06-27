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
  bool _showQr = false;

  _ShareDialogState(this._listId);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // title: const Text('Setup'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: _listId != null && !_showQr,
            child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: StadiumBorder(),
                  side: BorderSide(width: 2, color: Theme.of(context).accentColor),
                ),
                onPressed: () {
                  log('Share now');
                  setState(() {
                    _showQr = true;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.group, color: Theme.of(context).accentColor),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4,0,0,0),
                      child: Text(
                        "Share",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ],
                )),
          ),
          Visibility(
            visible: _listId != null && _showQr,
            child: Column(
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
                      padding: const EdgeInsets.fromLTRB(4, 8, 0, 0),
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
          ),
          // Text(_listId),
          Visibility(
            visible: !_showQr,
            child: Column(
              children: [
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: StadiumBorder(),
                      side: BorderSide(width: 1, color: Theme.of(context).disabledColor),
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
          child: Text('Cancel'),
        )
      ],
    );
  }
}

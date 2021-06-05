import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'dialog_result.dart';

class ShareDialog extends StatefulWidget {
  final String _accountId;

  ShareDialog(this._accountId);

  @override
  _ShareDialogState createState() => new _ShareDialogState(_accountId);
}

class _ShareDialogState extends State<ShareDialog> {
  final String _accountId;
  bool _showQr = false;

  _ShareDialogState(this._accountId);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // title: const Text('Setup'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: !_showQr,
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
            visible: _showQr,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  child: QrImage(
                    data: _accountId,
                    version: QrVersions.auto,
                    size: 200.0,
                    foregroundColor: Theme.of(context).accentColor,
                  ),
                ),
                Text(
                  "Scan this QR code on the other device to join.",
                  style: Theme.of(context).textTheme.caption,
                )
              ],
            ),
          ),
          // Text(_accountId),
          Visibility(
            visible: !_showQr,
            child: Column(
              children: [
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

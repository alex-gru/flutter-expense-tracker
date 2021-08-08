import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/utils/utils.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScanner extends StatefulWidget {
  const QrScanner();

  @override
  State<StatefulWidget> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR_Scanner');
  late QRViewController controller;
  bool _invalidQrProvided = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
              flex: 4,
              child: Stack(alignment: AlignmentDirectional.bottomCenter, children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  child: Visibility(
                      visible: _invalidQrProvided,
                      child:
                      Container(
                          decoration: ShapeDecoration(
                            color: Colors.red.shade900,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide.none
                            )
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text("Invalid QR code provided. Try again."),
                          ))),
                ),
              ])),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.group,
                          color: Theme.of(context).accentColor, size: 36),
                      Icon(Icons.qr_code,
                          color: Theme.of(context).accentColor, size: 36),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                      child: Text(
                          'Open the Expense Tracker app on the other device with the list in place.\n\n'
                          'Then scan the QR code that is displayed on the other device to join the list.'),
                    ),
                  ),
                ],
              )),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      isValidListId(scanData.code).then((isValid) {
        setState(() {
          _invalidQrProvided = !isValid;
        });
        if (!_invalidQrProvided) {
          Navigator.maybePop(context, scanData.code);
        }
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

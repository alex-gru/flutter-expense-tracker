import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/utils.dart';

class TotalBalance extends StatelessWidget {
  const TotalBalance({
    Key key,
    @required double balance,
    @required String person,
  }) : _total = balance, _person = person, super(key: key);

  final double _total;
  final String _person;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            niceAmount(_total),
            style: Theme.of(context).textTheme.headline4,
          ),
          Text(
            _person,
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ],
      ),
      message:
      'In total, $_person has spent ${niceAmount(_total)}',
    );
  }
}
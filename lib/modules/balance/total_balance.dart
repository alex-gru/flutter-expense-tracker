import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/utils.dart';

class TotalBalance extends StatelessWidget {
  const TotalBalance({
    Key key,
    @required double balance,
    @required String person, List<String> persons,
  }) : _total = balance, _person = person, _persons = persons, super(key: key);

  final double _total;
  final String _person;
  final List<String> _persons;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: [
              Text(
                prettifyAmount(_total),
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: Icon(
                    Icons.account_circle,
                    color: getPersonColor(_person, _persons),
                  ),
                ),
                Text(
                  _person,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
          ),
        ],
      ),
      message:
      'In total, $_person has spent ${prettifyAmount(_total)}',
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/utils.dart';

import '../person.dart';

class TotalBalance extends StatelessWidget {
  const TotalBalance({
    Key key,
    @required Person person,
    List<Person> persons,
  })  : _person = person,
        _persons = persons,
        super(key: key);

  final Person _person;
  final List<Person> _persons;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
            child: Row(
              children: [
                Text(
                  prettifyAmount(_person.sumExpenses),
                ),
              ],
            ),
          ),
          Divider(),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: Icon(
                  Icons.account_circle,
                  color: getPersonColor(_person.person, _persons),
                ),
              ),
              Text(
                _person.person,
                style: Theme.of(context).textTheme.headline6,
              ),
            ],
          ),
        ],
      ),
      message:
          'In total, ${_person.person} has spent ${prettifyAmount(_person.sumExpenses)}',
    );
  }
}

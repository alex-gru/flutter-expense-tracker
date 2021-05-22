import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/utils/utils.dart';

import '../dto/person.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    Key key,
    @required Person person,
  })  : _person = person,
        super(key: key);

  final Person _person;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: Icon(
                    Icons.account_circle,
                    color: getPersonColor(_person.person, context),
                  ),
                ),
                Text(
                  _person.person,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
          ),
        ],
      ),
      message:
          'In total, ${_person.person} has spent ${prettifyAmount(_person.sumExpenses)}',
    );
  }
}

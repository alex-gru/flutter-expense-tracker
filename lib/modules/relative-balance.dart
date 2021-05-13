import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/utils.dart';

class RelativeBalance extends StatelessWidget {
  final int _share;
  final String _person;
  final List<String> _persons;

  const RelativeBalance({
    Key key,
    @required int share, String person, List<String> persons,
  }) : _share = share, _person = person, _persons = persons, super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: getPersonColor(_person, _persons),
      ),
      flex: _share,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/utils.dart';

import '../person.dart';

class RelativeBalance extends StatelessWidget {
  final Person _person;
  final List<Person> _persons;

  const RelativeBalance({
    Key key, Person person, List<Person> persons,
  }) : _person = person, _persons = persons, super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: getPersonColor(_person.person, _persons),
      ),
      flex: _person.flex,
    );
  }
}
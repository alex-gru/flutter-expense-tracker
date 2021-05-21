import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/dto/person.dart';

import '../utils/utils.dart';

class BehindMarkerRelative extends StatelessWidget {
  final double _markerWidth = 100;

  const BehindMarkerRelative({
    Key key,
    @required List<Person> persons,
  })  : _persons = persons,
        super(key: key);

  final List<Person> _persons;

  @override
  Widget build(BuildContext context) {
    if (_persons.isEmpty) return Container();
    var _personBehind = _persons
        .reduce((person, other) => person.share < other.share ? person : other);
    var _personLeading = _persons
        .reduce((person, other) => person.share > other.share ? person : other);
    var _diff = (_personLeading.sumExpenses + _personBehind.sumExpenses) / 2 -
        _personBehind.sumExpenses;

    return Positioned(
      left: _persons.elementAt(0).progress - _markerWidth / 2,
      bottom: 60,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: _markerWidth,
              height: 20,
              color: getPersonColor(_personBehind.person, _persons),
            ),
          ),
          Text('${prettifyAmount(_diff)} behind')
        ],
      ),
    );
  }
}

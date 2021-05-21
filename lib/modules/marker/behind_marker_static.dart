import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/dto/person.dart';

import '../utils/utils.dart';

class BehindMarkerStatic extends StatelessWidget {
  final double _markerWidth = 100;
  final double _markerHeight = 25;

  const BehindMarkerStatic({
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

    double _middle = (_personBehind.progress + _personLeading.progress) / 2;

    var _left = _persons.elementAt(0).progress < _middle
        ? (_middle - _middle / 2)
        : (_middle + _middle / 2);

    var _diff = (_personLeading.sumExpenses + _personBehind.sumExpenses) / 2 -
        _personBehind.sumExpenses;

    if (_diff == 0) return Container();

    log('_middle: $_middle, _left: $_left');

    return Padding(
      padding: EdgeInsets.fromLTRB(_left - _markerWidth / 2, 16, 0, 0),
      child: Tooltip(
        message: '${_personBehind.person} is ${prettifyAmount(_diff)} behind.',
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            ClipRRect(
              child: Container(
                width: _markerWidth,
                height: _markerHeight,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: getPersonColor(_personBehind.person, _persons),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Text('- ${prettifyAmount(_diff)}')
          ],
        ),
      ),
    );
  }
}

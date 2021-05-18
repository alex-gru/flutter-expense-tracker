import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../person.dart';
import '../utils.dart';

class BehindMarker extends StatelessWidget {
  const BehindMarker({
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
    var _diff = (_personLeading.sumExpenses + _personBehind.sumExpenses) / 2 - _personBehind.sumExpenses;

    return Positioned(
      left: _persons.elementAt(0).progress - 80 / 2,
      bottom: 60,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 80,
              height: 20,
              color: getPersonColor(_personBehind.person, _persons),
            ),
          ),
          Text('- ${prettifyAmountWithoutCurrency(_diff)}')
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/state/app_state.dart';

import '../utils/utils.dart';

class BehindMarkerStatic extends StatelessWidget {
  final double _markerWidth = 100;
  final double _markerHeight = 25;

  const BehindMarkerStatic();

  @override
  Widget build(BuildContext context) {
    if (AppStateScope.of(context).persons.isEmpty) return Container();
    var personBehind = AppStateScope.of(context)
        .persons
        .reduce((person, other) => person.share < other.share ? person : other);
    var personLeading = AppStateScope.of(context)
        .persons
        .reduce((person, other) => person.share > other.share ? person : other);

    var middle = (personBehind.progress + personLeading.progress) / 2;

    var even = personLeading.progress == personBehind.progress;

    var left = even
        ? middle
        : AppStateScope.of(context).persons.elementAt(0).progress < middle
            ? (middle - middle / 2)
            : (middle + middle / 2);

    // diff to leading person
    var diff = personLeading.sumExpenses - personBehind.sumExpenses;

    // alternative: diff to average
    // var diff = (personLeading.sumExpenses + personBehind.sumExpenses) / 2 -
    //     personBehind.sumExpenses;

    return Opacity(
      opacity: 1,
      child: Padding(
        padding: EdgeInsets.fromLTRB(left - _markerWidth / 2, 16, 0, 0),
        child: Tooltip(
          message:
              '${personBehind.person} is ${prettifyAmount(diff.abs())} behind.',
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              ClipRRect(
                child: Container(
                  width: _markerWidth,
                  height: _markerHeight,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: even
                          ? Theme.of(context).accentColor
                          : getPersonColor(personBehind.person, context),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Text(even ? 'EVEN' : '- ${prettifyAmount(diff.abs())}')
            ],
          ),
        ),
      ),
    );
  }
}

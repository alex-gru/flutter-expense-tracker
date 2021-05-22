import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/state/app_state.dart';

import '../utils/utils.dart';

class BehindMarkerRelative extends StatelessWidget {
  final double _markerWidth = 100;

  const BehindMarkerRelative({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (AppStateScope.of(context).persons.isEmpty) return Container();
    var personBehind = AppStateScope.of(context)
        .persons
        .reduce((person, other) => person.share < other.share ? person : other);
    var personLeading = AppStateScope.of(context)
        .persons
        .reduce((person, other) => person.share > other.share ? person : other);
    var diff = (personLeading.sumExpenses + personBehind.sumExpenses) / 2 -
        personBehind.sumExpenses;

    return Positioned(
      left: AppStateScope.of(context).persons.elementAt(0).progress -
          _markerWidth / 2,
      bottom: 60,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: _markerWidth,
              height: 20,
              color: getPersonColor(personBehind.person, context),
            ),
          ),
          Text('${prettifyAmount(diff)} behind')
        ],
      ),
    );
  }
}

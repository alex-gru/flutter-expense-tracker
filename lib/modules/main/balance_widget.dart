import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/dto/person.dart';
import 'package:flutter_expense_tracker/modules/marker/behind_marker_static.dart';
import 'package:flutter_expense_tracker/modules/utils/utils.dart';

import '../balance/balance.dart';
import '../balance/person_avatar.dart';
import '../balance/align.dart' as align;

class BalanceWidget extends StatelessWidget {
  const BalanceWidget({
    Key key,
    @required List<Person> persons,
    @required this.relativeBalanceBarHeight,
  })  : _persons = persons,
        super(key: key);

  final List<Person> _persons;
  final double relativeBalanceBarHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _persons.isEmpty
                ? []
                : [
                    PersonAvatar(
                        person: _persons.elementAt(0), persons: _persons),
                    PersonAvatar(
                        person: _persons.elementAt(1), persons: _persons),
                  ],
          ),
          height: 50,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
                alignment: AlignmentDirectional.centerStart,
                child: BehindMarkerStatic(persons: _persons)),
            Container(
              alignment: AlignmentDirectional.bottomCenter,
              child: Stack(alignment: AlignmentDirectional.center, children: [
                Stack(alignment: AlignmentDirectional.center, children: [
                  Container(
                      height: relativeBalanceBarHeight,
                      child: Row(
                        children: _persons.isEmpty
                            ? []
                            : [
                                Balance(
                                    person: _persons.elementAt(0),
                                    persons: _persons,
                                    alignPercentage: align.Align.START),
                                Balance(
                                    person: _persons.elementAt(1),
                                    persons: _persons,
                                    alignPercentage: align.Align.END),
                              ],
                      )),
                  Stack(
                      alignment: AlignmentDirectional.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                            top: 30,
                            child: Text(
                              "50%",
                              style: Theme.of(context).textTheme.caption,
                            )),
                        Container(
                          width: 5,
                          height: relativeBalanceBarHeight + 10,
                          color: Theme.of(context).accentColor,
                          child: Container(),
                        )
                      ]),
                ]),
              ]),
              height: 40,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _persons.isEmpty
                    ? []
                    : [
                        Text(' ${prettifyAmount(_persons[0].sumExpenses)}'),
                        Text('${prettifyAmount(_persons[1].sumExpenses)} '),
                      ],
              ),
              height: 20,
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}

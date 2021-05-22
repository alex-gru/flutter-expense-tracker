import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/marker/behind_marker_static.dart';
import 'package:flutter_expense_tracker/modules/state/app_state.dart';
import 'package:flutter_expense_tracker/modules/utils/utils.dart';

import '../balance/align.dart' as align;
import '../balance/avatar.dart';
import '../balance/balance.dart';

class BalanceWidget extends StatelessWidget {
  const BalanceWidget({
    Key key,
    @required this.relativeBalanceBarHeight,
  }) : super(key: key);

  final double relativeBalanceBarHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: AppStateScope.of(context).persons.isEmpty
                ? []
                : [
                    Avatar(
                        person: AppStateScope.of(context).persons.elementAt(0)),
                    Avatar(
                        person: AppStateScope.of(context).persons.elementAt(1)),
                  ],
          ),
          height: 50,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
                alignment: AlignmentDirectional.centerStart,
                child: BehindMarkerStatic()),
            Container(
              alignment: AlignmentDirectional.bottomCenter,
              child: Stack(alignment: AlignmentDirectional.center, children: [
                Stack(alignment: AlignmentDirectional.center, children: [
                  Container(
                      height: relativeBalanceBarHeight,
                      child: Row(
                        children: AppStateScope.of(context).persons.isEmpty
                            ? []
                            : [
                                Balance(
                                    person: AppStateScope.of(context)
                                        .persons
                                        .elementAt(0),
                                    alignPercentage: align.Align.START),
                                Balance(
                                    person: AppStateScope.of(context)
                                        .persons
                                        .elementAt(1),
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
                children: AppStateScope.of(context).persons.isEmpty
                    ? []
                    : [
                        Text(
                            ' ${prettifyAmount(AppStateScope.of(context).persons[0].sumExpenses)}'),
                        Text(
                            '${prettifyAmount(AppStateScope.of(context).persons[1].sumExpenses)} '),
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

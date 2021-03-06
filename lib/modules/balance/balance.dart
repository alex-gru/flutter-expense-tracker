import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/modules/balance/align.dart' as align;
import 'package:flutter_expense_tracker/modules/utils/utils.dart';

import '../dto/person.dart';

class Balance extends StatelessWidget {
  final Person _person;
  final align.Align _align;

  const Balance({
    required Person person,
    required align.Align alignPercentage,
  })   : _person = person,
        _align = alignPercentage,
        super();

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _person.progress,
      child: Stack(
        alignment: getAlignment(),
        children: [
          Container(color: getPersonColor(_person.person, context)),
          Text(
            prettifyShare(_person.share),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  AlignmentDirectional getAlignment() => _align == align.Align.START
      ? AlignmentDirectional.centerStart
      : AlignmentDirectional.centerEnd;
}

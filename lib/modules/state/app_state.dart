import 'package:flutter/cupertino.dart';
import 'package:flutter_expense_tracker/modules/dto/expense.dart';
import 'package:flutter_expense_tracker/modules/dto/person.dart';

// Holds the shared state of the app
class AppState {
  AppState(this.persons, this.expenses);

  final List<Person> persons;
  final List<Expense> expenses;

  AppState copyWith({
    List<Person> persons,
    List<Expense> expenses,
  }) {
    return AppState(persons ?? this.persons, expenses ?? this.expenses);
  }
}

// TODO: switch to null safety! (pubspec.yaml)
class AppStateScope extends InheritedWidget {
  AppStateScope(this.data, {Key key, Widget child})
      : super(key: key, child: child);

  final AppState data;

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateScope>().data;
  }

  @override
  bool updateShouldNotify(AppStateScope oldWidget) {
    return data != oldWidget.data;
  }
}

class AppStateWidget extends StatefulWidget {
  AppStateWidget({this.child});

  final Widget child;

  static AppStateWidgetState of(BuildContext context) {
    return context.findAncestorStateOfType<AppStateWidgetState>();
  }

  @override
  AppStateWidgetState createState() => AppStateWidgetState();
}

class AppStateWidgetState extends State<AppStateWidget> {
  AppState _data = AppState([], []);

  void setPersons(List<Person> persons) {
    if (persons != _data.persons) {
      setState(() {
        _data = _data.copyWith(persons: persons);
      });
    }
  }

  void setExpenses(List<Expense> expenses) {
    if (expenses != _data.expenses) {
      setState(() {
        _data = _data.copyWith(expenses: expenses);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(_data, child: widget.child);
  }
}

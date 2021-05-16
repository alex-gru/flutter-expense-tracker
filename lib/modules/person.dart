class Person {
  String person;
  double sumExpenses;
  double share;
  int flex;

  Person(this.person, this.sumExpenses, this.share, this.flex);

  static create(String person) {
    return Person(person, 0, 0, 0);
  }

  withValues(double sumExpenses, double share, int flex) {
    return Person(this.person, sumExpenses, share, flex);
  }

  @override
  String toString() {
    return 'Person{person: $person, sumExpenses: $sumExpenses, share: $share, flex: $flex}';
  }
}

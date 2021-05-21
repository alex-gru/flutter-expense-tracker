class Person {
  String person;
  double sumExpenses;
  double share;
  double progress;

  Person(this.person, this.sumExpenses, this.share, this.progress);

  static create(String person) {
    return Person(person, 0, 0, 0);
  }

  withValues(double sumExpenses, double share, double progress) {
    return Person(this.person, sumExpenses, share, progress);
  }

  @override
  String toString() {
    return 'Person{person: $person, sumExpenses: $sumExpenses, share: $share, progress: $progress}';
  }
}

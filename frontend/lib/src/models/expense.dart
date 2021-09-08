class ExpenseModel {
  String email;
  double value;
  DateTime date;

  ExpenseModel({required this.email, required this.value, required this.date})
      : assert(email.trim().isNotEmpty),
        assert(value > 0),
        assert(date.isAfter(DateTime.now().subtract(const Duration(hours: 1))));

  factory ExpenseModel.fromJSON(Map<String, dynamic> json) {
    String email = (json['email'] as String).trim().toLowerCase();

    double value = double.parse(json['value']);

    // Parses ISO 8601 strings
    DateTime date = DateTime.parse(json['date']);

    return ExpenseModel(email: email, value: value, date: date);
  }
}

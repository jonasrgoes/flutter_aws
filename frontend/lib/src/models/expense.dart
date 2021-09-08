class ExpenseModel {
  DateTime? date;
  String email;
  double value;

  // The field "date" is not required to insert operations, but is required to read operations.
  // "date" is automatically generated by the backend based on now() datetime.
  ExpenseModel({required this.email, required this.value, this.date})
      : assert(email.trim().isNotEmpty),
        assert(value > 0);

  factory ExpenseModel.fromJSON(Map<String, dynamic> json) {
    String email = json['email'].trim().toLowerCase();

    double value = double.parse(json['value'].toString());

    // Parses ISO 8601 strings
    DateTime date = DateTime.parse(json['date']);

    return ExpenseModel(email: email, value: value, date: date);
  }
}

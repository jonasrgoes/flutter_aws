class FinanceModel {
  double totalSpent;
  double budget;

  FinanceModel({required this.totalSpent, required this.budget})
      : assert(!totalSpent.isNaN),
        assert(!totalSpent.isNegative),
        assert(!budget.isNaN),
        assert(!budget.isNegative);

  factory FinanceModel.fromJSON(Map<String, dynamic> json) {
    double totalSpent = double.parse(json['totalSpent']);
    double budget = double.parse(json['budget']);

    return FinanceModel(totalSpent: totalSpent, budget: budget);
  }
}

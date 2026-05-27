class Budget {
  final String id;
  final String categoryId;
  final double amount;
  final int month;
  final int year;
  final double spent;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
    required this.spent,
    required this.createdAt,
    required this.updatedAt,
  });

  double get remaining => amount - spent;
  double get percentage => amount > 0 ? (spent / amount) * 100 : 0;

  String get status {
    if (percentage >= 100) return 'exceeded';
    if (percentage >= 80) return 'warning';
    return 'safe';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'amount': amount,
        'month': month,
        'year': year,
        'spent': spent,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        id: json['id'] as String,
        categoryId: json['category_id'] as String,
        amount: (json['amount'] as num).toDouble(),
        month: json['month'] as int,
        year: json['year'] as int,
        spent: (json['spent'] as num).toDouble(),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Budget copyWith({
    String? id,
    String? categoryId,
    double? amount,
    int? month,
    int? year,
    double? spent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      spent: spent ?? this.spent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BudgetProgress {
  final Budget budget;
  final String categoryName;
  final int categoryIconCode;
  final int categoryColorValue;

  const BudgetProgress({
    required this.budget,
    required this.categoryName,
    required this.categoryIconCode,
    required this.categoryColorValue,
  });

  double get percentage => budget.percentage;
  String get status => budget.status;
}

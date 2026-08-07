double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

class CategoryModel {
  final String id;
  final String name;
  final String icon;

  CategoryModel({required this.id, required this.name, this.icon = ''});

  factory CategoryModel.fromJson(dynamic json) {
    if (json is String) return CategoryModel(id: json, name: json);
    final map = json as Map<String, dynamic>;
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? map['id']?.toString() ?? '',
      icon: map['icon']?.toString() ?? '',
    );
  }
}

class SummaryModel {
  final double totalIncome;
  final double totalExpense;
  final double balance;

  SummaryModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      totalIncome: _toDouble(json['totalIncome']),
      totalExpense: _toDouble(json['totalExpense']),
      balance: _toDouble(json['balance']),
    );
  }
}

class CategoryBreakdownModel {
  final String category;
  final String type;
  final double total;
  final int count;

  CategoryBreakdownModel({
    required this.category,
    this.type = '',
    required this.total,
    required this.count,
  });

  factory CategoryBreakdownModel.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownModel(
      category: json['category']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      total: _toDouble(json['total']),
      count: _toInt(json['count']),
    );
  }
}

class PaginationModel {
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;

  PaginationModel({
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: _toInt(json['page']),
      limit: _toInt(json['limit']),
      totalItems: _toInt(json['totalItems']),
      totalPages: _toInt(json['totalPages']),
    );
  }
}

class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String category;
  final String description;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.description = '',
    required this.date,
  });

  bool get isIncome => type == 'income';

  String get displayTitle => description.isNotEmpty ? description : category;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'expense',
      amount: _toDouble(json['amount']),
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String().split('T').first,
    };
  }
}

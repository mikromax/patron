// lib/models/import_file_details_dto.dart
import 'import_expense_dto.dart';
import 'import_item_dto.dart';
import 'import_expense_distribution_dto.dart';

class ImportFileDetailsDto {
  final List<ImportExpenseDto> expenses;
  final List<ImportItemDto> items;
  final List<ImportExpenseDistributionDto> importExpenseDistributions;

  ImportFileDetailsDto({
    required this.expenses,
    required this.items,
    required this.importExpenseDistributions,
  });

  factory ImportFileDetailsDto.fromJson(Map<String, dynamic> json) {
    var expensesList = (json['expenses'] as List<dynamic>?)
        ?.map((i) => ImportExpenseDto.fromJson(i as Map<String, dynamic>))
        .toList() ?? [];
    
    var itemsList = (json['items'] as List<dynamic>?)
        ?.map((i) => ImportItemDto.fromJson(i as Map<String, dynamic>))
        .toList() ?? [];
        
    var distList = (json['importExpenseDistributions'] as List<dynamic>?)
        ?.map((i) => ImportExpenseDistributionDto.fromJson(i as Map<String, dynamic>))
        .toList() ?? [];

    return ImportFileDetailsDto(
      expenses: expensesList,
      items: itemsList,
      importExpenseDistributions: distList,
    );
  }
}
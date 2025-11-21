import 'package:dio/dio.dart';
import '../../models/result_model.dart';
import '../../models/item_transaction_dto.dart';
import '../../models/account_types.dart';
import '../../models/customer_account_group_dto.dart';
import '../../models/get_customer_account_groups_query.dart';
import '../../models/balance_aging_chart_vm.dart';
import '../../models/get_account_balance_aging_chart_query.dart';
import '../../models/CreditLimit/customer_limit_dto.dart';
import 'core/api_client.dart';

class FinanceApi {
  final Dio _dio = ApiClient().dio;

  Future<List<ItemTransactionDto>> getAccountTransactionStatement({
    required AccountTypes accountType,
    required String accountCode,
    required int groupId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final queryParameters = {
        'accountType': accountType.value.toString(),
        'accountCode': accountCode,
        'groupId': groupId.toString(),
        'startDate': startDate.toIso8601String().split('T').first,
        'endDate': endDate.toIso8601String().split('T').first,
      };

      final response = await _dio.get(
        'api/AccountTransactions/getaccounttransactionstatement',
        queryParameters: queryParameters,
      );
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => ItemTransactionDto.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  Future<AccountTypes> detectAccountType(String code) async {
    try {
      final response = await _dio.get(
        'api/AccountTransactions/detectaccounttype',
        queryParameters: {'code': code},
      );
      final resultModel = ResultModel<int>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return AccountTypes.values.firstWhere((e) => e.value == resultModel.result);
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  Future<List<CustomerAccountGroupDto>> getCustomerAccountGroups(GetCustomerAccountGroupsQuery query) async {
    try {
      final response = await _dio.get(
        'api/AccountTransactions/getaccountgroups',
        queryParameters: query.toQueryParameters(),
      );
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => CustomerAccountGroupDto.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  Future<List<BalanceAgingChartVM>> getAccountBalanceAgingChart(GetAccountBalanceAgingChartQuery query) async {
    try {
      final response = await _dio.get(
        'api/AccountTransactions/getbalanceagingchart',
        queryParameters: query.toQueryParameters(),
      );
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => BalanceAgingChartVM.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  Future<List<CustomerLimitDto>> getCustomerCurrentLimit(String customerCode) async {
    try {
      final response = await _dio.get('api/creditlimit/current-limit/$customerCode');
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => CustomerLimitDto.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}
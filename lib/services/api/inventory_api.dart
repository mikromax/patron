import 'package:dio/dio.dart';
import '../../models/result_model.dart';
import '../../models/inventory_status_dto.dart';
import '../../models/get_inventory_status_query.dart';
import '../../models/item_price_dto.dart';
import '../../models/get_item_prices_query.dart';
import '../../models/item_transaction_dto.dart';
import '../../models/item_transaction_statement_query.dart';
import '../../models/item_last_transactions_query.dart';
import '../../models/orders_by_customer_vm.dart';
import '../../models/get_all_orders_by_item_query.dart';
import 'core/api_client.dart';

class InventoryApi {
  final Dio _dio = ApiClient().dio;

  Future<List<InventoryStatusDto>> getInventoryStatus(GetInventoryStatusQuery query) async {
    try {
      final response = await _dio.get(
        'api/Items/getiteminventorydetails',
        queryParameters: query.toQueryParameters(),
      );
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => InventoryStatusDto.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  Future<List<ItemPriceDto>> getItemAllPrices(GetItemPricesQuery query) async {
    try {
      final response = await _dio.get(
        'api/Items/getitemprices',
        queryParameters: query.toQueryParameters(),
      );
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => ItemPriceDto.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  Future<List<ItemTransactionDto>> getItemTransactionStatement(ItemTransactionStatementQuery query) async {
    try {
      final response = await _dio.get(
        'api/Items/getitemtransactionstatement',
        queryParameters: query.toQueryParameters(),
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

  Future<List<ItemTransactionDto>> getItemLastTransactions(ItemLastTransactionsQuery query) async {
    try {
      final response = await _dio.get(
        'api/Items/getlastitemtransactions',
        queryParameters: query.toQueryParameters(),
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

  Future<List<OrdersByCustomerVM>> searchOrdersByItem(GetAllOrdersByItemQuery query) async {
    try {
      final response = await _dio.get(
        'api/Orders/getordersbyitem',
        queryParameters: query.toQueryParameters(),
      );
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => OrdersByCustomerVM.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}
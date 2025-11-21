import 'package:dio/dio.dart';
import '../../models/result_model.dart';
// Modeller
import '../../models/orders_by_customer_vm.dart';
import '../../models/get_all_orders_by_customer_query.dart';
import '../../models/Helpers/base_card_view_model.dart';
import '../../models/cancel_with_quantity_command.dart';
import '../../models/approve_with_quantity_command.dart';
// Motor
import 'core/api_client.dart';

class OrdersApi {
  final Dio _dio = ApiClient().dio;

  // 1. Müşteriye Göre Siparişleri Arama
  Future<List<OrdersByCustomerVM>> searchOrdersByCustomer(GetAllOrdersByCustomerQuery query) async {
    try {
      final response = await _dio.get(
        'mikro/Order/SearchOrdersByCustomer',
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

  // 2. Sipariş İptal Nedenlerini Getirme
  Future<List<BaseCardViewModel>> getOrderCancelReasons() async {
    try {
      // Not: Endpoint isminde "Resons" yazım hatası API tarafında varsa aynen koruyoruz
      final response = await _dio.get('mikro/Order/GetOrderCancelResons');
      
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => BaseCardViewModel.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 3. Miktarlı Sipariş Kapatma (İptal)
  Future<bool> cancelOrderWithQuantity(CancelWithQuantityCommand command) async {
    try {
      final response = await _dio.post(
        'mikro/SalesOrders/CancelWithQuantity',
        data: command.toJson(),
      );

      final resultModel = ResultModel.fromJson(response.data);
      if (resultModel.isSuccessful) {
        return true;
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // 4. Miktarlı Sipariş Onaylama
  Future<bool> approveOrderWithQuantity(ApproveWithQuantityCommand command) async {
    try {
      final response = await _dio.post(
        'mikro/SalesOrders/ApproveWithQuantity',
        data: command.toJson(),
      );

      final resultModel = ResultModel.fromJson(response.data);
      if (resultModel.isSuccessful) {
        return true;
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}
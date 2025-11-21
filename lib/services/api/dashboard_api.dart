import 'package:dio/dio.dart';
import '../../models/result_model.dart';
import '../../models/nakit_varliklar_model.dart';
import '../../models/account_credit_debit_status_dto.dart';
import '../../models/get_account_credit_debit_status_query.dart';
import '../../models/bank_credits_vm.dart';
import '../../models/get_bank_credits_query.dart';
import '../../models/nonecash_assets_vm.dart';
import '../../models/get_nonecash_assets_query.dart';
import 'core/api_client.dart';

class DashboardApi {
  final Dio _dio = ApiClient().dio;

  // Nakit Varlıklar
  Future<NakitVarliklar> getCashAssets() async {
    try {
      final response = await _dio.get('api/Dashboards/getcashassets');
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        List<Detail> detailsList = resultModel.result!
            .map((item) => Detail.fromJson(item))
            .toList();
        return NakitVarliklar(details: detailsList);
      } else {
        throw Exception(resultModel.errors.join('\n'));
      }
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // Borçlar / Alacaklar
  Future<List<AccountCreditDebitStatusDto>> getAccountCreditDebitStatus(GetAccountCreditDebitStatusQuery query) async {
    try {
      final response = await _dio.get(
        'api/Dashboards/getaccountbalances',
        queryParameters: query.toQueryParameters(),
      );
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => AccountCreditDebitStatusDto.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // Krediler
  Future<List<BankCreditsVM>> getBankCredits(GetBankCreditsQuery query) async {
    try {
      final response = await _dio.get(
        'mikro/MikroCashAsstesInfo/GetBankCredits',
        queryParameters: query.toQueryParameters(),
      );
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => BankCreditsVM.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }

  // Değerli Kağıtlar
  Future<List<NonecashAssetsVM>> getNoneCashAssets(GetNoneCashAssetsQuery query) async {
    try {
      final response = await _dio.get(
        'api/Dashboards/getnonecashassets',
        queryParameters: query.toQueryParameters(),
      );
      final resultModel = ResultModel<List<dynamic>>.fromJson(response.data);

      if (resultModel.isSuccessful && resultModel.result != null) {
        return resultModel.result!
            .map((item) => NonecashAssetsVM.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error);
    }
  }
}
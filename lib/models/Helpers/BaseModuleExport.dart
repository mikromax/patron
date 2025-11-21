export 'base_card_view_model.dart';
export 'paginated_result.dart';
export 'paginated_search_query.dart';
export 'search_type.dart';
import 'paginated_result.dart';
import 'base_card_view_model.dart';
import 'paginated_search_query.dart';
typedef PaginatedSearchFunction = Future<PaginatedResult<BaseCardViewModel>> Function(PaginatedSearchQuery query);

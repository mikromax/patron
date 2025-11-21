class PaginatedResult<T> {
  final List<T> data;
  final int currentPage;
  final int pageSize;
 final int totalCount;
  int get totalPages => (totalCount / pageSize).ceil();

  PaginatedResult({
    required this.data,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
  });

  factory PaginatedResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    final itemsList = (json['data'] as List<dynamic>?)
        ?.map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList() ?? [];
    
    return PaginatedResult<T>(
      data: itemsList,
      totalCount: json['totalCount'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
    );
  }
}
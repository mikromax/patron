class PaginatedSearchQuery {
  int pageNumber;
  int pageSize;
  String? codeFilter;
  String? descriptionFilter;

  PaginatedSearchQuery({
    this.pageNumber = 1,
    this.pageSize = 20,
    this.codeFilter,
    this.descriptionFilter,
  });

  Map<String, String> toQueryParameters() {
    return {
      'PageNumber': pageNumber.toString(),
      'PageSize': pageSize.toString(),
      if (codeFilter != null && codeFilter!.isNotEmpty) 'CodeFilter': codeFilter!,
      if (descriptionFilter != null && descriptionFilter!.isNotEmpty) 'DescriptionFilter': descriptionFilter!,
    };
  }
}
class ApiResponse {
  final List<dynamic> data;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  ApiResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      data: json['data'],
      currentPage: json['pagination']['currentPage'],
      totalPages: json['pagination']['totalPages'],
      totalItems: json['pagination']['totalItems'],
      itemsPerPage: json['pagination']['itemsPerPage'],
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mongodb_api/models/data_model.dart';

// const String baseUrl = 'https://rainy-thundering-catcher.glitch.me/data';

Future<ApiResponse> fetchPaginatedData(
    {required int limit, required int page}) async {
  const String baseUrl = 'https://rainy-thundering-catcher.glitch.me/data';
  final Uri url = Uri.parse('$baseUrl?limit=$limit&page=$page');

  final http.Response response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> json = jsonDecode(response.body);
    return ApiResponse.fromJson(json);
  } else {
    throw Exception('Failed to load data');
  }
}

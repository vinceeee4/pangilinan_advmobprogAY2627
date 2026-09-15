import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/constants.dart';
import '../models/product_model.dart';

class ProductService {
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final http.Response response = await http.get(Uri.parse(kApiUrl));

      if (response.statusCode != 200) {
        throw Exception('Server returned status ${response.statusCode}.');
      }

      final dynamic jsonData = jsonDecode(response.body);
      final List<dynamic> rawProducts = jsonData is Map<String, dynamic>
          ? (jsonData['products'] as List<dynamic>? ?? <dynamic>[])
          : (jsonData is List ? jsonData : <dynamic>[]);

      return rawProducts
          .map((dynamic item) => ProductModel.fromJson(item as Map<String, dynamic>?))
          .toList();
    } catch (error) {
      throw Exception('Unable to load products: $error');
    }
  }
}

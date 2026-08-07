import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/product_model.dart';

class ProductService {
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final String body = await rootBundle.loadString('assets/products.json');
      final dynamic jsonData = jsonDecode(body);

      if (jsonData is List) {
        return jsonData
            .map((dynamic item) => ProductModel.fromJson(item as Map<String, dynamic>?))
            .toList();
      }

      throw Exception('Invalid local product data.');
    } catch (error) {
      throw Exception('Unable to load local products: $error');
    }
  }
}

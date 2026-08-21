import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import '../models/cart.dart';

class CartService {
  final http.Client _client;
  CartService({http.Client? client}) : _client = client ?? http.Client();

  // Enhancement 3: Retrieves only the selected user's cart from DummyJSON.
  Future<Cart?> getCartByUserId(int userId) async {
    try {
      final http.Response response = await _client
          .get(Uri.parse('$kDummyJsonBaseUrl/carts/user/$userId'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200)
        throw Exception('Unable to load cart (HTTP ${response.statusCode}).');
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['carts'] is! List)
        throw Exception('Invalid cart response from the server.');
      final List<dynamic> carts = decoded['carts'] as List<dynamic>;
      if (carts.isEmpty || carts.first is! Map<String, dynamic>) return null;
      return Cart.fromJson(carts.first as Map<String, dynamic>);
    } catch (error) {
      throw Exception('Could not load the user cart: $error');
    }
  }

  // Enhancement 3: Sends product IDs and quantities to DummyJSON /carts/add.
  Future<Cart> addToCart({
    required int userId,
    required List<CartProductRequest> products,
  }) async {
    try {
      final http.Response response = await _client
          .post(
            Uri.parse('$kDummyJsonBaseUrl/carts/add'),
            headers: const <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(<String, dynamic>{
              'userId': userId,
              'products': products
                  .map((CartProductRequest product) => product.toJson())
                  .toList(),
            }),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200 && response.statusCode != 201)
        throw Exception(
          'Unable to add cart item (HTTP ${response.statusCode}).',
        );
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>)
        throw Exception('Invalid add-cart response from the server.');
      return Cart.fromJson(decoded);
    } catch (error) {
      throw Exception('Could not add the product to the cart: $error');
    }
  }
}

import 'product_model.dart';

class CartProduct {
  final int id;
  final String title;
  final double price;
  final int quantity;
  final double total;
  final double discountedTotal;
  final String thumbnail;

  const CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountedTotal,
    required this.thumbnail,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    double number(dynamic value) =>
        value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
    int integer(dynamic value) =>
        value is int ? value : int.tryParse('$value') ?? 0;
    return CartProduct(
      id: integer(json['id']),
      title: json['title']?.toString() ?? 'Unknown product',
      price: number(json['price']),
      quantity: integer(json['quantity']),
      total: number(json['total']),
      discountedTotal: number(json['discountedTotal']),
      thumbnail: json['thumbnail']?.toString() ?? '',
    );
  }

  ProductModel toProductModel() => ProductModel(
    id: id,
    title: title,
    description: 'This product was opened from the user cart.',
    category: 'Cart product',
    image: thumbnail,
    price: price,
    rating: const Rating(rate: 0, count: 0),
  );
}

class Cart {
  final int id;
  final List<CartProduct> products;
  final double total;
  final double discountedTotal;
  final int userId;
  final int totalProducts;
  final int totalQuantity;

  const Cart({
    required this.id,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.userId,
    required this.totalProducts,
    required this.totalQuantity,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    double number(dynamic value) =>
        value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
    int integer(dynamic value) =>
        value is int ? value : int.tryParse('$value') ?? 0;
    final List<dynamic> rawProducts =
        json['products'] as List<dynamic>? ?? <dynamic>[];
    return Cart(
      id: integer(json['id']),
      products: rawProducts
          .whereType<Map<String, dynamic>>()
          .map(CartProduct.fromJson)
          .toList(),
      total: number(json['total']),
      discountedTotal: number(json['discountedTotal']),
      userId: integer(json['userId']),
      totalProducts: integer(json['totalProducts']),
      totalQuantity: integer(json['totalQuantity']),
    );
  }
}

class CartProductRequest {
  final int id;
  final int quantity;
  const CartProductRequest({required this.id, required this.quantity});
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'quantity': quantity,
  };
}

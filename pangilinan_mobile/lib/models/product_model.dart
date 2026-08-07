import '../constants/constants.dart';

class Rating {
  final double rate;
  final int count;

  const Rating({required this.rate, required this.count});

  factory Rating.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const Rating(rate: 0.0, count: 0);
    }

    final dynamic rawRate = json['rate'];
    final dynamic rawCount = json['count'];

    return Rating(
      rate: rawRate is num ? rawRate.toDouble() : double.tryParse('$rawRate') ?? 0.0,
      count: rawCount is int ? rawCount : int.tryParse('$rawCount') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'rate': rate,
      'count': count,
    };
  }
}

class ProductModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final String image;
  final double price;
  final Rating rating;

  double get pricePhp => price * kUsdToPhpConversionRate;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.image,
    required this.price,
    required this.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ProductModel(
        id: 0,
        title: 'Unknown product',
        description: 'No description',
        category: 'Unknown',
        image: '',
        price: 0.0,
        rating: Rating(rate: 0.0, count: 0),
      );
    }

    final dynamic rawId = json['id'];
    final dynamic rawPrice = json['price'];

    return ProductModel(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      title: json['title']?.toString() ?? 'Unknown product',
      description: json['description']?.toString() ?? 'No description',
      category: json['category']?.toString() ?? 'Unknown',
      image: json['image']?.toString() ?? '',
      price: rawPrice is num ? rawPrice.toDouble() : double.tryParse('$rawPrice') ?? 0.0,
      rating: Rating.fromJson(json['rating'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'image': image,
      'price': price,
      'rating': rating.toJson(),
    };
  }
}

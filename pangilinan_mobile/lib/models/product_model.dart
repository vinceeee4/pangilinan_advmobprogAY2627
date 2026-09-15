import '../constants/constants.dart';

class Rating {
  final double rate;
  final int count;

  const Rating({required this.rate, required this.count});

  factory Rating.fromJson(dynamic json) {
    if (json is num) {
      // dummyjson.com returns a plain numeric rating with no review count.
      return Rating(rate: json.toDouble(), count: 0);
    }

    if (json is Map<String, dynamic>) {
      final dynamic rawRate = json['rate'];
      final dynamic rawCount = json['count'];

      return Rating(
        rate: rawRate is num ? rawRate.toDouble() : double.tryParse('$rawRate') ?? 0.0,
        count: rawCount is int ? rawCount : int.tryParse('$rawCount') ?? 0,
      );
    }

    return const Rating(rate: 0.0, count: 0);
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

    // dummyjson.com uses 'thumbnail'/'images' instead of fakestoreapi's
    // single 'image' field; support all three so this keeps working
    // regardless of which API shape a given branch was pointed at.
    final dynamic rawImages = json['images'];
    final dynamic rawSingleImage = json['thumbnail'] ?? json['image'];
    final String image = rawSingleImage != null
        ? rawSingleImage.toString()
        : (rawImages is List && rawImages.isNotEmpty ? rawImages.first.toString() : '');

    return ProductModel(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      title: json['title']?.toString() ?? 'Unknown product',
      description: json['description']?.toString() ?? 'No description',
      category: json['category']?.toString() ?? 'Unknown',
      image: image,
      price: rawPrice is num ? rawPrice.toDouble() : double.tryParse('$rawPrice') ?? 0.0,
      rating: Rating.fromJson(json['rating']),
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

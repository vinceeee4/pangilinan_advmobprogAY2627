import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/product_model.dart';
import '../widgets/custom_text.dart';

class DetailsScreen extends StatelessWidget {
  final ProductModel product;

  const DetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Enhancement 2: Details Page
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kBorderRadius),
                child: Image.network(
                  product.image,
                  height: 250,
                  fit: BoxFit.contain,
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => const Icon(Icons.broken_image, size: 120),
                ),
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            CustomText(product.title, style: kProductTitleStyle),
            const SizedBox(height: 8),
            CustomText('Category: ${product.category}', style: kProductSubtitleStyle),
            const SizedBox(height: 8),
            CustomText('Price: $kCurrencySymbol${product.pricePhp.toStringAsFixed(2)}', style: kProductPriceStyle),
            const SizedBox(height: 8),
            CustomText('Rating: ${product.rating.rate} (${product.rating.count} reviews)', style: kProductSubtitleStyle),
            const SizedBox(height: kDefaultPadding),
            CustomText(product.description),
          ],
        ),
      ),
    );
  }
}

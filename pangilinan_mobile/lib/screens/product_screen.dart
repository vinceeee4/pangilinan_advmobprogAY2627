import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'details_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _service = ProductService();
  late Future<List<ProductModel>> _futureProducts;
  List<ProductModel> _products = <ProductModel>[];
  List<ProductModel> _filteredProducts = <ProductModel>[];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _futureProducts = _fetchProducts();
  }

  Future<List<ProductModel>> _fetchProducts() async {
    final List<ProductModel> products = await _service.fetchProducts();
    _products = products;
    _filteredProducts = products;
    return products;
  }

  void _filterProducts(String value) {
    setState(() {
      _searchText = value;
      _filteredProducts = _searchText.isEmpty
          ? _products
          : _products
              .where((ProductModel product) =>
                  product.title.toLowerCase().contains(_searchText.toLowerCase()))
              .toList();
    });
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _futureProducts = _fetchProducts();
    });
    await _futureProducts;
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      elevation: kCardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      margin: const EdgeInsets.only(bottom: kDefaultPadding),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(kBorderRadius),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => DetailsScreen(product: product),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.network(
                    product.image,
                    fit: BoxFit.contain,
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => const Icon(Icons.broken_image),
                  ),
                ),
                const SizedBox(width: kDefaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomText(
                        product.title,
                        style: kProductTitleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      CustomText(product.category, style: kProductSubtitleStyle),
                      const SizedBox(height: 8),
                      CustomText('$kCurrencySymbol${product.pricePhp.toStringAsFixed(2)}', style: kProductPriceStyle),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: _futureProducts,
      builder: (BuildContext context, AsyncSnapshot<List<ProductModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const CustomText('Failed to load products.'),
                  const SizedBox(height: 8),
                  CustomText(snapshot.error.toString()),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshProducts,
                    child: const CustomText('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final List<ProductModel> products = snapshot.data ?? <ProductModel>[];
        if (products.isEmpty) {
          return const Center(child: CustomText('No products available.'));
        }

        return RefreshIndicator(
          onRefresh: _refreshProducts,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(kDefaultPadding),
            children: <Widget>[
              // Enhancement 1: Search Bar
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Search products',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _filterProducts,
              ),
              const SizedBox(height: kDefaultPadding),
              if (_filteredProducts.isEmpty)
                const Center(child: CustomText('No matching products found.'))
              else
                ..._filteredProducts.map<Widget>(_buildProductCard),
            ],
          ),
        );
      },
    );
  }
}

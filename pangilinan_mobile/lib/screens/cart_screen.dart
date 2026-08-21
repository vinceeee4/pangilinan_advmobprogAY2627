import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';
import 'details_screen.dart';

// Enhancement 1: Renders the selected user's DummyJSON cart; cart items open DetailsScreen.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.userId = kTestUserId});

  final int userId;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  late Future<Cart?> _cartFuture;

  @override
  void initState() {
    super.initState();
    _cartFuture = _cartService.getCartByUserId(widget.userId);
  }

  Future<void> _reload() async {
    setState(() => _cartFuture = _cartService.getCartByUserId(widget.userId));
    await _cartFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: FutureBuilder<Cart?>(
        future: _cartFuture,
        builder: (BuildContext context, AsyncSnapshot<Cart?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) {
            return Center(child: Padding(padding: const EdgeInsets.all(kDefaultPadding), child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[const CustomText('Failed to load the cart.'), const SizedBox(height: 8), CustomText(snapshot.error.toString(), textAlign: TextAlign.center), const SizedBox(height: 16), ElevatedButton(onPressed: _reload, child: const Text('Retry'))])));
          }
          final Cart? cart = snapshot.data;
          if (cart == null || cart.products.isEmpty) return const Center(child: CustomText('No cart found for this user.'));
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.all(kDefaultPadding),
              children: <Widget>[
                Card(child: Padding(padding: const EdgeInsets.all(kDefaultPadding), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[CustomText('User ID: ${cart.userId}', style: kProductTitleStyle), const SizedBox(height: 4), CustomText('Cart #${cart.id} • ${cart.totalQuantity} item(s)')])),
                ),
                const SizedBox(height: kDefaultPadding),
                ...cart.products.map((CartProduct product) => _cartItem(product)),
                Card(child: Padding(padding: const EdgeInsets.all(kDefaultPadding), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[CustomText('Total: $kCurrencySymbol${cart.total.toStringAsFixed(2)}', style: kProductPriceStyle), const SizedBox(height: 4), CustomText('Discounted total: $kCurrencySymbol${cart.discountedTotal.toStringAsFixed(2)}')]))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cartItem(CartProduct product) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(kBorderRadius),
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DetailsScreen(product: product.toProductModel()))),
          child: Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Row(children: <Widget>[SizedBox(width: 72, height: 72, child: Image.network(product.thumbnail, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[CustomText(product.title, style: kProductTitleStyle, maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), CustomText('$kCurrencySymbol${product.price.toStringAsFixed(2)}'), CustomText('Qty: ${product.quantity}') ])), const Icon(Icons.arrow_forward_ios, size: 18)]),
          ),
        ),
      );
}

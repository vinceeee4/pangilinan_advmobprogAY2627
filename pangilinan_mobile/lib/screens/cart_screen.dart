import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';
import 'details_screen.dart';
import 'settings_screen.dart';

// Enhancement 1: Renders the selected user's DummyJSON cart; cart items open DetailsScreen.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.userId = kTestUserId});

  final int userId;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color _blue = Color(0xFF3F51A0);
  static const Color _yellow = Color(0xFFFFC42D);
  final CartService _cartService = CartService();
  final Map<int, int> _quantities = <int, int>{};
  late Future<Cart?> _cartFuture;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _cartFuture = _loadCart();
  }

  Future<Cart?> _loadCart() async {
    final Cart? cart = await _cartService.getCartByUserId(widget.userId);
    if (cart != null) {
      for (final CartProduct product in cart.products) {
        _quantities[product.id] = product.quantity;
      }
    }
    return cart;
  }

  Future<void> _reload() async {
    setState(() => _cartFuture = _loadCart());
    await _cartFuture;
  }

  void _changeQuantity(CartProduct product, int change) {
    final int current = _quantities[product.id] ?? product.quantity;
    final int updated = current + change;
    if (updated < 1) return;
    setState(() => _quantities[product.id] = updated);
  }

  Future<void> _confirmOrder(Cart cart) async {
    setState(() => _isConfirming = true);
    try {
      await _cartService.addToCart(
        userId: cart.userId,
        products: cart.products
            .map((CartProduct product) => CartProductRequest(
                  id: product.id,
                  quantity: _quantities[product.id] ?? product.quantity,
                ))
            .toList(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order submitted to the DummyJSON cart simulation.')),
        );
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9FF),
      appBar: AppBar(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        title: const Text('Cart'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: FutureBuilder<Cart?>(
        future: _cartFuture,
        builder: (BuildContext context, AsyncSnapshot<Cart?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return _errorState(snapshot.error.toString());
          final Cart? cart = snapshot.data;
          if (cart == null || cart.products.isEmpty) return const Center(child: CustomText('No cart found for this user.'));
          return _cartBody(cart);
        },
      ),
      // Enhancement 2: CartScreen has no chat FAB, so it is hidden on this page.
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  Widget _errorState(String error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            const CustomText('Failed to load the cart.'),
            const SizedBox(height: 8),
            CustomText(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _reload, child: const Text('Retry')),
          ]),
        ),
      );

  Widget _cartBody(Cart cart) {
    final double subtotal = cart.products.fold<double>(0, (double sum, CartProduct product) => sum + product.price * (_quantities[product.id] ?? product.quantity));
    final double discount = cart.products.fold<double>(0, (double sum, CartProduct product) {
      final int quantity = _quantities[product.id] ?? product.quantity;
      final double originalTotal = product.total == 0 ? product.price * product.quantity : product.total;
      final double saved = originalTotal - product.discountedTotal;
      final double discountRate = originalTotal == 0 ? 0 : saved / originalTotal;
      return sum + (product.price * quantity * discountRate);
    });
    final double total = subtotal - discount;

    return Column(children: <Widget>[
      Expanded(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            children: <Widget>[
              ...cart.products.map(_cartItem),
              const SizedBox(height: 10),
              _summaryRow('Subtotal:', subtotal),
              _summaryRow('Discount:', -discount),
              const Divider(height: 22),
              _summaryRow('Total:', total, bold: true),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _yellow, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: _isConfirming ? null : () => _confirmOrder(cart),
            child: _isConfirming ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Text('Confirm Order', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ]);
  }

  Widget _cartItem(CartProduct product) {
    final int quantity = _quantities[product.id] ?? product.quantity;
    final double lineTotal = product.price * quantity;
    final double originalTotal = product.total == 0 ? product.price * product.quantity : product.total;
    final int discountPercent = originalTotal == 0 ? 0 : ((1 - product.discountedTotal / originalTotal) * 100).round();
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DetailsScreen(product: product.toProductModel()))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: Row(children: <Widget>[
            SizedBox(width: 72, height: 82, child: Image.network(product.thumbnail, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              CustomText(product.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5),
              Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: _yellow, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('$discountPercent% off • \$${lineTotal.toStringAsFixed(2)} total', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ])),
            Column(children: <Widget>[
              _quantityButton(Icons.add, _yellow, () => _changeQuantity(product, 1)),
              Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w700))),
              _quantityButton(Icons.remove, const Color(0xFFE9EAF0), quantity > 1 ? () => _changeQuantity(product, -1) : null),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, Color color, VoidCallback? onPressed) => SizedBox(
        width: 34,
        height: 34,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.black, padding: EdgeInsets.zero, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
          child: Icon(icon, size: 19),
        ),
      );

  Widget _summaryRow(String label, double amount, {bool bold = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
          Text('\$${amount.toStringAsFixed(2)}', style: TextStyle(color: _yellow, fontWeight: FontWeight.w700, fontSize: bold ? 16 : 14)),
        ]),
      );

  Widget _bottomNavigation() => BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: _blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (int index) {
          if (index == 0) Navigator.of(context).pop();
          if (index == 2) Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      );
}

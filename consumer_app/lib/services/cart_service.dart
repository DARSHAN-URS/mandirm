import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final String mandir;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.mandir,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'mandir': mandir,
        'price': price,
        'imageUrl': imageUrl,
        'quantity': quantity,
      };
}

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];
  final ValueNotifier<int> cartCountNotifier = ValueNotifier<int>(0);

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal =>
      _items.fold(0.0, (sum, i) => sum + (i.price * i.quantity));

  void addItem(Map<String, dynamic> product, {int quantity = 1}) {
    final id = product['id']?.toString() ?? 'prod_${product.hashCode}';
    final existingIndex = _items.indexWhere((item) => item.id == id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      final double price = (product['priceNumeric'] as num?)?.toDouble() ??
          (product['price'] as num?)?.toDouble() ??
          (double.tryParse(product['price']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '') ?? 499.0);

      _items.add(CartItem(
        id: id,
        title: product['title']?.toString() ?? product['name']?.toString() ?? 'Consecrated Spiritual Item',
        mandir: product['mandir']?.toString() ?? product['source_temple']?.toString() ?? 'Mandirm Divine Store',
        price: price,
        imageUrl: product['image']?.toString() ?? product['image_url']?.toString() ?? '',
        quantity: quantity,
      ));
    }

    _notify();
  }

  void updateQuantity(String productId, int quantity) {
    final idx = _items.indexWhere((i) => i.id == productId);
    if (idx >= 0) {
      if (quantity <= 0) {
        _items.removeAt(idx);
      } else {
        _items[idx].quantity = quantity;
      }
      _notify();
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.id == productId);
    _notify();
  }

  void clearCart() {
    _items.clear();
    _notify();
  }

  void _notify() {
    cartCountNotifier.value = totalCount;
  }
}

import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../utils/database_helper.dart';

// CartProvider class to manage the state of the cart using ChangeNotifier
class CartProvider with ChangeNotifier {
  // Private list of cart items
  List<CartItem> _items = [];

  // Instance of DatabaseHelper to handle database operations
  final DatabaseHelper _db = DatabaseHelper();

  // Public getter to access cart items
  List<CartItem> get items => _items;

  // Get the total count of items in the cart
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // Get the total price of all items in the cart
  double get totalPrice => _items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  // Load cart items from the database and notify listeners
  Future<void> loadCartItems(List<Product> products) async {
    _items = await _db.getCartItems(products);  // Fetch items from the database
    notifyListeners();  // Notify UI of changes
  }

  // Initialize the cart by loading items from the database
  Future<void> initCart(List<Product> products) async {
    await loadCartItems(products);  // Load items from the database
  }

  // Add a product to the cart, or increase its quantity if it already exists
  Future<void> addToCart(Product product) async {
    final existingItemIndex = _items.indexWhere((item) => item.product.id == product.id);

    // If product already exists in the cart, increase its quantity
    if (existingItemIndex != -1) {
      _items[existingItemIndex].quantity++;
      await _db.updateCartItem(_items[existingItemIndex]);  // Update the database
    } else {
      // If product doesn't exist, add a new item to the cart
      final newItem = CartItem(product: product, quantity: 1);
      _items.add(newItem);
      await _db.insertCartItem(newItem);  // Insert the new item into the database
    }
    notifyListeners();  // Notify UI of changes
  }

  // Remove a product from the cart and the database
  Future<void> removeFromCart(Product product) async {
    _items.removeWhere((item) => item.product.id == product.id);  // Remove the item from the list
    await _db.deleteCartItem(product.id);  // Delete the item from the database
    notifyListeners();  // Notify UI of changes
  }

  // Decrease the quantity of a product in the cart or remove it if quantity is 1
  Future<void> decreaseQuantity(Product product) async {
    final itemIndex = _items.indexWhere((item) => item.product.id == product.id);

    // If the item is found in the cart
    if (itemIndex != -1) {
      if (_items[itemIndex].quantity > 1) {
        // If quantity is more than 1, decrease the quantity
        _items[itemIndex].quantity--;
        await _db.updateCartItem(_items[itemIndex]);  // Update the database
      } else {
        // If quantity is 1, remove the item from the cart
        await removeFromCart(product);
      }
      notifyListeners();  // Notify UI of changes
    }
  }

  // Clear all items from the cart and the database
  Future<void> clearCart() async {
    _items.clear();  // Clear the list of items
    await _db.clearCart();  // Clear the items from the database
    notifyListeners();  // Notify UI of changes
  }
}

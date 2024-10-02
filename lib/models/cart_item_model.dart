import 'package:flutter_task/models/product_model.dart';

class CartItem {

  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1,});

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, Product product) {
    return CartItem(
      product: product,
      quantity: map['quantity'],
    );
  }
}
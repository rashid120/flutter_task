import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class DatabaseHelper {
  // Singleton database instance
  static Database? _database;

  // Getter for the database instance, initializes if not already initialized
  Future<Database> get database async {
    // If the database already exists, return it
    if (_database != null) return _database!;
    // Otherwise, initialize the database
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database and create the 'cart_items' table if it doesn't exist
  Future<Database> _initDatabase() async {
    // Get the path for the database
    String path = join(await getDatabasesPath(), 'grocery_cart.db');

    // Open the database, and create the 'cart_items' table
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cart_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,  // Auto-incrementing primary key
            productId INTEGER,  // Foreign key to the product
            quantity INTEGER  // Quantity of the product in the cart
          )
        ''');
      },
    );
  }

  // Insert a new cart item into the 'cart_items' table
  Future<void> insertCartItem(CartItem item) async {
    final db = await database;  // Get the database instance
    await db.insert('cart_items', item.toMap());  // Insert the item as a map
  }

  // Update an existing cart item in the 'cart_items' table based on productId
  Future<void> updateCartItem(CartItem item) async {
    final db = await database;  // Get the database instance
    await db.update(
      'cart_items',
      item.toMap(),  // Convert the CartItem object to a map
      where: 'productId = ?',  // Update the item where productId matches
      whereArgs: [item.product.id],  // The value to match for the productId
    );
  }

  // Delete a cart item from the 'cart_items' table based on productId
  Future<void> deleteCartItem(int productId) async {
    final db = await database;  // Get the database instance
    await db.delete(
      'cart_items',
      where: 'productId = ?',  // Delete the item where productId matches
      whereArgs: [productId],  // The value to match for the productId
    );
  }

  // Get all cart items and map them to CartItem objects
  Future<List<CartItem>> getCartItems(List<Product> products) async {
    final db = await database;  // Get the database instance
    final List<Map<String, dynamic>> maps = await db.query('cart_items');  // Fetch all rows from 'cart_items'

    // Generate a list of CartItem objects from the map, finding the corresponding product for each
    return List.generate(maps.length, (index) {
      final productId = maps[index]['productId'] as int;  // Extract productId from the map
      final product = products.firstWhere((p) => p.id == productId);  // Find the matching product by id
      return CartItem.fromMap(maps[index], product);  // Create a CartItem object from the map and product
    });
  }

  // Clear all cart items by deleting everything in the 'cart_items' table
  Future<void> clearCart() async {
    final db = await database;  // Get the database instance
    await db.delete('cart_items');  // Delete all rows from 'cart_items'
  }
}

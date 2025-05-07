class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int quantity;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'] ?? '', // Handle both '_id' and 'id'
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
        if (id.isNotEmpty) '_id': id, // Include ID for updates
      };
}
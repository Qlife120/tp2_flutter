class ClothingItem {
  final String title;
  final String category;
  final String size;
  final String brand;
  final double price;

  ClothingItem({
    required this.title,
    required this.category,
    required this.size,
    required this.brand,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'size': size,
      'brand': brand,
      'price': price,
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      title: map['title'],
      category: map['category'],
      size: map['size'],
      brand: map['brand'],
      price: map['price'],
    );
  }
}

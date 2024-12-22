class ClothingItem {
  final String title;
  final String category;
  final String size;
  final String brand;
  final double price;
  final String? imageBase64;  // Add imageBase64 field

  ClothingItem({
    required this.title,
    required this.category,
    required this.size,
    required this.brand,
    required this.price,
    this.imageBase64,  // Add imageBase64 to the constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'size': size,
      'brand': brand,
      'price': price,
      'imageBase64': imageBase64,  // Save imageBase64 in the map
    };
  }
}

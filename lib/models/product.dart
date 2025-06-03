class Product {
  final String title;
  final num price;
  final num rating;
  final String thumbnail;
  final String category;

  Product({
    required this.title,
    required this.price,
    required this.rating,
    required this.thumbnail,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['title'] ?? '',
      price: json['price'] ?? 0,
      rating: json['rating'] ?? 0,
      thumbnail: json['thumbnail'] ?? '',
      category: json['category'] ?? 'Unknown',
    );
  }
}

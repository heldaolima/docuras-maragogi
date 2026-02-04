class ProductBoxModel {
  final int? id;
  final int productId;
  final int price;
  final int unitsPerBox;

  ProductBoxModel({
    this.id,
    required this.productId,
    required this.price,
    required this.unitsPerBox,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'price': price,
      'units_per_box': unitsPerBox,
    };
  }

  factory ProductBoxModel.fromMap(Map<String, dynamic> map) {
    return ProductBoxModel(
      id: map['id'],
      productId: map['product_id'],
      price: map['price'],
      unitsPerBox: map['units_per_box'],
    );
  }
}

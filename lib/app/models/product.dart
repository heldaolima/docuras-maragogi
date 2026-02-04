class ProductModel {
  final int? id;
  final String name;
  final int unitRetailPrice;
  final int unitWholesalePrice;

  ProductModel({
    this.id,
    required this.name,
    required this.unitRetailPrice,
    required this.unitWholesalePrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit_retail_price': unitRetailPrice,
      'unit_wholesale_price': unitWholesalePrice,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      unitRetailPrice: map['unit_retail_price'],
      unitWholesalePrice: map['unit_wholesale_price'],
    );
  }
}


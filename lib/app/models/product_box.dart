import 'package:docuras_maragogi/app/models/product.dart';

class ProductBoxModel {
  final int? id;
  final int productId;
  final int price;
  final int unitsPerBox;
  ProductModel? product;

  ProductBoxModel({
    this.id,
    required this.productId,
    required this.price,
    required this.unitsPerBox,
    this.product,
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

  factory ProductBoxModel.fromJoinQuery(Map<String, dynamic> map) {
    return ProductBoxModel(
        productId: map['product_box_id'] as int,
        price: map['pb_price'] as int,
        unitsPerBox: map['pb_units_per_box'] as int,
        product: ProductModel.fromJoinQuery(map)
    );
  }
}

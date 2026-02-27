import 'package:docuras_maragogi/app/models/product_box.dart';

class OrderProductModel {
  final int? id;
  final int? orderId;
  final int productBoxId;
  final int quantity;
  final int price;
  final ProductBoxModel? productBox;

  OrderProductModel({
    this.id,
    this.orderId,
    required this.productBoxId,
    required this.quantity,
    required this.price,
    this.productBox,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_box_id': productBoxId,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderProductModel.fromMap(Map<String, dynamic> map) {
    return OrderProductModel(
      id: map['id'],
      orderId: map['order_id'],
      productBoxId: map['product_box_id'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }

  factory OrderProductModel.fromJoinQuery(
    Map<String, dynamic> map,
    int orderId,
  ) {
    return OrderProductModel(
      id: map['op_id'] as int,
      orderId: orderId,
      productBoxId: map['product_box_id'] as int,
      quantity: map['op_quantity'] as int,
      price: map['op_price'] as int,
      productBox: ProductBoxModel.fromJoinQuery(map),
    );
  }

  OrderProductModel copyWith({int? orderId}) {
    return OrderProductModel(
      id: id,
      orderId: orderId ?? this.orderId,
      productBoxId: productBoxId,
      quantity: quantity,
      price: price,
    );
  }
}

class OrderProductModel {
  final int? id;
  final int? orderId;
  final int productBoxId;
  final int quantity;
  final int price;

  OrderProductModel({
    this.id,
    this.orderId,
    required this.productBoxId,
    required this.quantity,
    required this.price,
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

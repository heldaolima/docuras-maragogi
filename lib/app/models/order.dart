class OrderModel {
  final int? id;
  final int clientId;
  final int numberPerClient;
  final DateTime orderDate;

  OrderModel({
    this.id,
    required this.clientId,
    required this.numberPerClient,
    required this.orderDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'number_per_client': numberPerClient,
      'order_date': orderDate.millisecondsSinceEpoch,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      clientId: map['client_id'],
      numberPerClient: map['number_per_client'],
      orderDate: DateTime.fromMillisecondsSinceEpoch(map['order_date']),
    );
  }
}

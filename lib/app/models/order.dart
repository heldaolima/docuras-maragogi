import 'package:docuras_maragogi/app/models/client.dart';
import 'package:docuras_maragogi/app/models/order_product.dart';

class OrderModel {
  final int? id;
  final int clientId;
  final int numberPerClient;
  final DateTime orderDate;
  ClientModel? client;
  List<OrderProductModel>? orderProducts;

  OrderModel({
    this.id,
    required this.clientId,
    required this.numberPerClient,
    required this.orderDate,
    this.client,
    this.orderProducts,
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

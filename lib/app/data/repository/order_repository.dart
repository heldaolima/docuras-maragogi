import 'package:docuras_maragogi/app/data/dao/order_dao.dart';
import 'package:docuras_maragogi/app/data/dao/order_product_dao.dart';
import 'package:docuras_maragogi/app/data/db/db.dart';
import 'package:docuras_maragogi/app/models/client.dart';
import 'package:docuras_maragogi/app/models/order.dart';
import 'package:docuras_maragogi/app/models/order_product.dart';

class OrderRepository {
  final _orderProductDao = OrderProductDao();
  final _orderDao = OrderDao();

  Future<int> createOrder(
    OrderModel order,
    List<OrderProductModel> items,
  ) async {
    final db = await DbProvider.instance.database;

    return await db.transaction((txn) async {
      final orderId = await txn.insert('orders', order.toMap());

      for (final item in items) {
        await txn.insert(
          'order_product',
          item.copyWith(orderId: orderId).toMap(),
        );
      }

      return orderId;
    });
  }

  Future<List<OrderProductModel>> getItemsByOrder(int orderId) {
    return _orderProductDao.findByOrder(orderId);
  }

  Future<List<OrderModel>> getByClient(int clientId) {
    return _orderDao.findByClient(clientId);
  }

  Future<List<OrderModel>> getAll() {
    return _orderDao.findAll();
  }

  Future<void> update(OrderModel order) {
    return _orderDao.update(order);
  }

  Future<void> delete(int id) {
    return _orderDao.delete(id);
  }

  Future<OrderModel?> findById(int id) {
    return _orderDao.findById(id);
  }

  Future<List<OrderModel>> getAllWithClient() async {
    final db = await DbProvider.instance.database;
    final result = await db.rawQuery('''
      SELECT o.*, c.id as client_id, c.name, c.contact
      FROM orders o
      INNER JOIN client c ON o.client_id = c.id
      ORDER BY o.order_date DESC
    ''');

    return result.map((map) {
      final order = OrderModel.fromMap(map);
      order.client = _clientModelFromQuery(map);
      return order;
    }).toList();
  }

  ClientModel _clientModelFromQuery(Map<String, Object?> map) {
    return ClientModel(
      id: map['client_id'] as int?,
      name: map['name'] as String,
      contact: map['contact'] as String?,
    );
  }

  /// Retorna todas as orders com cliente e seus produtos
  Future<List<OrderModel>> getAllWithClientAndProducts() async {
    final db = await DbProvider.instance.database;
    final result = await db.rawQuery('''
      SELECT o.id, o.client_id, o.number_per_client, o.order_date,
             c.id as client_id, c.name, c.contact,
             op.id as op_id, op.product_box_id, op.quantity, op.price
      FROM orders o
      INNER JOIN client c ON o.client_id = c.id
      LEFT JOIN order_product op ON o.id = op.order_id
      ORDER BY o.order_date DESC, op.id
    ''');

    final Map<int, OrderModel> ordersMap = {};

    for (var map in result) {
      final orderId = map['id'] as int;

      if (!ordersMap.containsKey(orderId)) {
        final order = OrderModel.fromMap(map);
        order.client = _clientModelFromQuery(map);
        order.orderProducts = [];
        ordersMap[orderId] = order;
      }

      if (map['op_id'] != null) {
        ordersMap[orderId]!.orderProducts!.add(
          _orderProductFromQuery(map, orderId),
        );
      }
    }

    return ordersMap.values.toList();
  }

  OrderProductModel _orderProductFromQuery(
    Map<String, Object?> map,
    int orderId,
  ) {
    return OrderProductModel(
      id: map['op_id'] as int,
      orderId: orderId,
      productBoxId: map['product_box_id'] as int,
      quantity: map['quantity'] as int,
      price: map['price'] as int,
    );
  }

  /// Retorna uma order específica com dados do cliente
  Future<OrderModel?> getByIdWithClient(int id) async {
    final db = await DbProvider.instance.database;
    final result = await db.rawQuery('''
      SELECT o.*, c.id as client_id, c.name, c.contact
      FROM orders o
      INNER JOIN client c ON o.client_id = c.id
      WHERE o.id = ?
    ''', [id]);

    if (result.isEmpty) {
      return null;
    }

    final map = result.first;
    final order = OrderModel.fromMap(map);
    order.client = _clientModelFromQuery(map);
    return order;
  }

  /// Retorna uma order específica com cliente e seus produtos
  Future<OrderModel?> getByIdWithClientAndProducts(int id) async {
    final db = await DbProvider.instance.database;
    final result = await db.rawQuery('''
      SELECT o.id, o.client_id, o.number_per_client, o.order_date,
             c.id as client_id, c.name, c.contact,
             op.id as op_id, op.product_box_id, op.quantity, op.price
      FROM orders o
      INNER JOIN client c ON o.client_id = c.id
      LEFT JOIN order_product op ON o.id = op.order_id
      WHERE o.id = ?
      ORDER BY op.id
    ''', [id]);

    if (result.isEmpty) {
      return null;
    }

    final map = result.first;
    final order = OrderModel.fromMap(map);
    order.client = _clientModelFromQuery(map);
    order.orderProducts = [];

    for (var row in result) {
      if (row['op_id'] != null) {
        order.orderProducts!.add(_orderProductFromQuery(row, order.id!));
      }
    }

    return order;
  }
}

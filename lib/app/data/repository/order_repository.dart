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

  Future<void> update(
    OrderModel order,
    List<OrderProductModel>? orderProducts,
  ) async {
    final db = await DbProvider.instance.database;

    await db.transaction((txn) async {
      await txn.update(
        'orders',
        order.toMap(),
        where: 'id = ?',
        whereArgs: [order.id!],
      );

      if (orderProducts != null) {
        // in this case, an update is easier if it is a reset
        // because of the [OrderProductModel] instances
        await txn.delete(
          'order_product',
          where: 'order_id = ?',
          whereArgs: [order.id],
        );
        for (final item in orderProducts) {
          await txn.insert('order_product', {
            ...item.toMap(),
            'order_id': order.id!,
          });
        }
      }
    });
  }

  Future<void> delete(int id) async {
    final db = await DbProvider.instance.database;
    await db.transaction((txn) async {
      await txn.delete('order_product', where: 'order_id = ?', whereArgs: [id]);
      await txn.delete('orders', where: 'id = ?', whereArgs: [id]);
    });

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
      order.client = ClientModel.fromJoinQuery(map);
      return order;
    }).toList();
  }

  /// Retorna todas as orders com cliente e seus produtos
  Future<List<OrderModel>> getAllWithClientAndProducts() async {
    final db = await DbProvider.instance.database;
    final result = await db.rawQuery('''
      SELECT o.id, o.client_id, o.number_per_client, o.order_date,
             c.id as client_id, c.name as c_name, c.contact as c_contact,
             op.id as op_id, op.product_box_id, op.quantity as op_quantity, op.price as op_price,
             pb.id as pb_id, pb.product_id, pb.units_per_box as pb_units_per_box, pb.price as pb_price,
             p.id as p_id, p.name as product_name, p.unit_retail_price p_unit_retail_price, p.unit_wholesale_price as p_unit_wholesale_price
      FROM orders o
      INNER JOIN client c ON o.client_id = c.id
      LEFT JOIN order_product op ON o.id = op.order_id
      LEFT JOIN product_box pb ON op.product_box_id = pb.id
      LEFT JOIN product p ON pb.product_id = p.id
      ORDER BY o.order_date DESC, op.id
    ''');

    final Map<int, OrderModel> ordersMap = {};

    for (var map in result) {
      final orderId = map['id'] as int;

      if (!ordersMap.containsKey(orderId)) {
        final order = OrderModel.fromMap(map);
        order.client = ClientModel.fromJoinQuery(map);
        order.orderProducts = [];
        ordersMap[orderId] = order;
      }

      if (map['op_id'] != null) {
        ordersMap[orderId]!.orderProducts!.add(
          OrderProductModel.fromJoinQuery(map, orderId),
        );
      }
    }

    return ordersMap.values.toList();
  }

  /// Retorna uma order específica com dados do cliente
  Future<OrderModel?> getByIdWithClient(int id) async {
    final db = await DbProvider.instance.database;
    final result = await db.rawQuery(
      '''
      SELECT o.*, c.id as client_id, c.name as c_name, c.contact as c_contact
      FROM orders o
      INNER JOIN client c ON o.client_id = c.id
      WHERE o.id = ?
    ''',
      [id],
    );

    if (result.isEmpty) {
      return null;
    }

    final map = result.first;
    final order = OrderModel.fromMap(map);
    order.client = ClientModel.fromJoinQuery(map);
    return order;
  }

  /// Retorna uma order específica com cliente e seus produtos
  Future<OrderModel?> getByIdWithClientAndProducts(int id) async {
    final db = await DbProvider.instance.database;
    final result = await db.rawQuery(
      '''
      SELECT o.id, o.client_id, o.number_per_client, o.order_date,
             c.id as client_id, c.name as c_name, c.contact as c_contact,
             op.id as op_id, op.product_box_id, op.quantity as op_quantity, op.price as op_price,
             pb.id as pb_id, pb.product_id, pb.units_per_box as pb_units_per_box, pb.price as pb_price,
             p.id as p_id, p.name as product_name, p.unit_retail_price as p_unit_retail_price, p.unit_wholesale_price as p_unit_wholesale_price
      FROM orders o
      INNER JOIN client c ON o.client_id = c.id
      LEFT JOIN order_product op ON o.id = op.order_id
      LEFT JOIN product_box pb ON op.product_box_id = pb.id
      LEFT JOIN product p ON pb.product_id = p.id
      WHERE o.id = ?
      ORDER BY op.id
    ''',
      [id],
    );

    if (result.isEmpty) {
      return null;
    }

    final map = result.first;
    final order = OrderModel.fromMap(map);

    order.client = ClientModel.fromJoinQuery(map);
    order.orderProducts = [];

    for (var row in result) {
      if (row['op_id'] != null) {
        order.orderProducts!.add(
          OrderProductModel.fromJoinQuery(row, order.id!),
        );
      }
    }

    return order;
  }

  Future<OrderModel?> getLastByClient(int clientId) async {
    final db = await DbProvider.instance.database;
    final result = await db.rawQuery(
      '''
      SELECT o.*, c.id as client_id, c.name as c_name, c.contact as c_contact
      FROM orders o
      INNER JOIN client c ON o.client_id = c.id
      WHERE o.client_id = ?
      ORDER BY o.number_per_client DESC
      LIMIT 1
    ''',
      [clientId],
    );

    if (result.isEmpty) {
      return null;
    }

    final map = result.first;
    final order = OrderModel.fromMap(map);
    order.client = ClientModel.fromJoinQuery(map);

    return order;
  }
}

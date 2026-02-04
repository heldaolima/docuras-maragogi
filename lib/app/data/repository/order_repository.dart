import 'package:docuras_maragogi/app/data/dao/order_dao.dart';
import 'package:docuras_maragogi/app/data/dao/order_product_dao.dart';
import 'package:docuras_maragogi/app/data/db/db.dart';
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
}

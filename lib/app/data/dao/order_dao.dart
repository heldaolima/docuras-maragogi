import 'package:docuras_maragogi/app/data/db/db.dart';
import 'package:docuras_maragogi/app/models/order.dart';

class OrderDao {
  final String _table = 'orders';

  Future<int> insert(OrderModel order) async {
    final db = await DbProvider.instance.database;
    return db.insert(_table, order.toMap());
  }

  Future<List<OrderModel>> findByClient(int clientId) async {
    final db = await DbProvider.instance.database;
    final result = await db.query(
      _table,
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'order_date DESC',
    );

    return result.map(OrderModel.fromMap).toList();
  }

  Future<List<OrderModel>> findAll() async {
    final db = await DbProvider.instance.database;
    final result = await db.query(_table);
    return result.map(OrderModel.fromMap).toList();
  }

  Future<OrderModel?> findById(int id) async {
    final db = await DbProvider.instance.database;
    final result = await db.query(_table, where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) {
      return null;
    }

    return OrderModel.fromMap(result.first);
  }

  Future<void> update(OrderModel client) async {
    final db = await DbProvider.instance.database;
    await db.update(
      _table,
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await DbProvider.instance.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}

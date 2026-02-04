import 'package:docuras_maragogi/app/data/db/db.dart';
import 'package:docuras_maragogi/app/models/order_product.dart';

class OrderProductDao {
  final String _table = 'order_product';

  Future<int> insert(OrderProductModel item) async {
    final db = await DbProvider.instance.database;
    return db.insert(_table, item.toMap());
  }

  Future<List<OrderProductModel>> findByOrder(int orderId) async {
    final db = await DbProvider.instance.database;
    final result = await db.query(
      _table,
      where: 'order_id = ?',
      whereArgs: [orderId],
    );

    return result.map(OrderProductModel.fromMap).toList();
  }


  Future<void> delete(int id) async {
    final db = await DbProvider.instance.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

}

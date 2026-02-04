import 'package:docuras_maragogi/app/data/db/db.dart';
import 'package:docuras_maragogi/app/models/product_box.dart';

class ProductBoxDao {
  final String _table = 'product_box';
  Future<int> insert(ProductBoxModel box) async {
    final db = await DbProvider.instance.database;
    return db.insert(_table, box.toMap());
  }

  Future<List<ProductBoxModel>> findAll() async {
    final db = await DbProvider.instance.database;
    final result = await db.query(_table);
    return result.map(ProductBoxModel.fromMap).toList();
  }

  Future<ProductBoxModel?> findById(int id) async {
    final db = await DbProvider.instance.database;
    final result = await db.query(_table, where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) {
      return null;
    }

    return ProductBoxModel.fromMap(result.first);
  }

  Future<void> update(ProductBoxModel box) async {
    final db = await DbProvider.instance.database;
    await db.update(
      _table,
      box.toMap(),
      where: 'id = ?',
      whereArgs: [box.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await DbProvider.instance.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
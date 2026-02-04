import 'package:docuras_maragogi/app/data/db/db.dart';
import 'package:docuras_maragogi/app/models/product.dart';

class ProductDao {
  final String _table = 'product';
  Future<int> insert(ProductModel product) async {
    final db = await DbProvider.instance.database;
    return db.insert(_table, product.toMap());
  }

  Future<List<ProductModel>> findAll() async {
    final db = await DbProvider.instance.database;
    final result = await db.query(_table);
    return result.map(ProductModel.fromMap).toList();
  }

  Future<void> update(ProductModel product) async {
    final db = await DbProvider.instance.database;
    await db.update(
      _table,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await DbProvider.instance.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<ProductModel?> findById(int id) async {
    final db = await DbProvider.instance.database;
    final result = await db.query(_table, where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) {
      return null;
    }

    return ProductModel.fromMap(result.first);
  }
}
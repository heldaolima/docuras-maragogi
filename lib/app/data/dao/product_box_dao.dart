import 'package:docuras_maragogi/app/data/db/db.dart';
import 'package:docuras_maragogi/app/models/product.dart';
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

  Future<List<ProductBoxModel>> findAllWithProduct() async {
    final db = await DbProvider.instance.database;
    final result = await db.rawQuery('''
    SELECT
      pb.id AS pb_id,
      pb.product_id AS pb_product_id,
      pb.price AS pb_price,
      pb.units_per_box AS pb_units_per_box,
      p.id AS p_id,
      p.name AS p_name,
      p.unit_retail_price AS p_unit_retail_price,
      p.unit_wholesale_price AS p_unit_wholesale_price
    FROM product_box pb
    JOIN product p ON p.id = pb.product_id
  ''');

    return result.map(_mapRowToProductBox).toList();
  }

  ProductBoxModel _mapRowToProductBox(Map<String, dynamic> row) {
    return ProductBoxModel(
      id: row['pb_id'] as int,
      productId: row['pb_product_id'] as int,
      price: row['pb_price'] as int,
      unitsPerBox: row['pb_units_per_box'] as int,
      product: ProductModel(
        id: row['p_id'] as int,
        name: row['p_name'] as String,
        unitRetailPrice: row['p_unit_retail_price'] as int,
        unitWholesalePrice: row['p_unit_wholesale_price'] as int,
      ),
    );
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
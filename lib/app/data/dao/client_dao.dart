import 'package:docuras_maragogi/app/data/db/db.dart';
import 'package:docuras_maragogi/app/models/client.dart';

class ClientDao {
  final String _table = 'client';

  Future<int> insert(ClientModel client) async {
    final db = await DbProvider.instance.database;
    return db.insert(_table, client.toMap());
  }

  Future<List<ClientModel>> findAll() async {
    final db = await DbProvider.instance.database;
    final result = await db.query(_table);
    return result.map(ClientModel.fromMap).toList();
  }

  Future<ClientModel?> findById(int id) async {
    final db = await DbProvider.instance.database;
    final result = await db.query(_table, where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) {
      return null;
    }

    return ClientModel.fromMap(result.first);
  }

  Future<void> update(ClientModel client) async {
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

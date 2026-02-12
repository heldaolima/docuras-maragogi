import 'package:docuras_maragogi/app/data/db/db.dart';
import 'package:docuras_maragogi/app/models/file.dart';

class FileDao {
  Future<int> insert(FileModel file) async {
    final db = await DbProvider.instance.database;
    return db.insert('files', file.toMap());
  }

  Future<FileModel?> findById(int id) async {
    final db = await DbProvider.instance.database;
    final result = await db.query('files', where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) return null;
    return FileModel.fromMap(result.first);
  }

  /// Deletes a file record by id. Returns number of rows deleted (0 or 1).
  Future<int> delete(int id) async {
    final db = await DbProvider.instance.database;
    return db.delete('files', where: 'id = ?', whereArgs: [id]);
  }
}

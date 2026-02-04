import 'package:docuras_maragogi/app/data/db/db.dart';
import 'package:docuras_maragogi/app/models/company.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class CompanyDao {
  final String _table = 'company';
  Future<void> save(CompanyModel company) async {
    final db = await DbProvider.instance.database;
    await db.insert(
      _table,
      company.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<CompanyModel?> get() async {
    final db = await DbProvider.instance.database;

    final result = await db.query(_table, where: 'id = 1');
    if (result.isEmpty) {
      return null;
    }

    return CompanyModel.fromMap(result.first);
  }
}
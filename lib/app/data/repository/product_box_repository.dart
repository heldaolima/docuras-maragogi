import 'package:docuras_maragogi/app/data/dao/product_box_dao.dart';
import 'package:docuras_maragogi/app/models/product_box.dart';

class ClientRepository {
  final _boxDao = ProductBoxDao();

  Future<int> create(ProductBoxModel box) {
    return _boxDao.insert(box);
  }

  Future<List<ProductBoxModel>> getAll() {
    return _boxDao.findAll();
  }

  Future<void> update(ProductBoxModel box) {
    return _boxDao.update(box);
  }

  Future<void> delete(int id) {
    return _boxDao.delete(id);
  }

  Future<ProductBoxModel?> findById(int id) {
    return _boxDao.findById(id);
  }

}


import 'package:docuras_maragogi/app/data/dao/product_box_dao.dart';
import 'package:docuras_maragogi/app/data/dao/product_dao.dart';
import 'package:docuras_maragogi/app/models/product_box.dart';

class ProductBoxRepository {
  final _boxDao = ProductBoxDao();
  final _productDao = ProductDao();

  Future<int> create(ProductBoxModel box) {
    return _boxDao.insert(box);
  }

  Future<List<ProductBoxModel>> getAll() {
    return  _boxDao.findAll();
  }

  Future<List<ProductBoxModel>> getAllWithProduct() {
    return _boxDao.findAllWithProduct();
  }

  Future<void> update(ProductBoxModel box) {
    return _boxDao.update(box);
  }

  Future<void> delete(int id) {
    return _boxDao.delete(id);
  }

  Future<ProductBoxModel?> findById(int id) async {
    ProductBoxModel? box = await _boxDao.findById(id);
    if (box != null) {
      final product = await _productDao.findById(box.productId);
      box.product = product;
    }

    return box;
  }
}


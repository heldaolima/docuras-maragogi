import 'package:docuras_maragogi/app/data/dao/product_dao.dart';
import 'package:docuras_maragogi/app/models/product.dart';

class ProductRepository {
  final _productDao = ProductDao();

  Future<int> create(ProductModel biscuit) {
    return _productDao.insert(biscuit);
  }

  Future<List<ProductModel>> getAll() {
    return _productDao.findAll();
  }

  Future<void> update(ProductModel product) {
    return _productDao.update(product);
  }

  Future<void> delete(int id) {
    return _productDao.delete(id);
  }

  Future<ProductModel?> findById(int id) {
    return _productDao.findById(id);
  }
}

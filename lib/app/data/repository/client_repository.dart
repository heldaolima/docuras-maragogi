import 'package:docuras_maragogi/app/data/dao/client_dao.dart';
import 'package:docuras_maragogi/app/models/client.dart';

class ClientRepository {
  final _clientDao = ClientDao();

  Future<int> create(ClientModel client) {
    return _clientDao.insert(client);
  }

  Future<List<ClientModel>> getAll() {
    return _clientDao.findAll();
  }

  Future<void> update(ClientModel client) {
    return _clientDao.update(client);
  }

  Future<void> delete(int id) {
    return _clientDao.delete(id);
  }

  Future<ClientModel?> findById(int id) {
    return _clientDao.findById(id);
  }

}

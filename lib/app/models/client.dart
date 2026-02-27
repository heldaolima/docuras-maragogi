class ClientModel {
  final int? id;
  final String name;
  final String? contact;

  ClientModel({this.id, required this.name, this.contact});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
    );
  }

  factory ClientModel.fromJoinQuery(Map<String, dynamic> map) {
    return ClientModel(
      id: map['client_id'],
      name: map['c_name'],
      contact: map['c_contact'],
    );
  }
}

class FileModel {
  final int? id;
  final String path;

  FileModel({ this.id, required this.path });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
    };
  }

  factory FileModel.fromMap(Map<String, dynamic> map) {
    return FileModel(
      id: map['id'] as int?,
      path: map['path'] as String,
    );
  }
}
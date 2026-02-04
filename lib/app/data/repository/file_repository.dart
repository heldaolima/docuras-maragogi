import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:docuras_maragogi/app/models/file.dart';

class FileRepository {
  /// Copies [sourceFile] into the application support files directory and
  /// returns a [FileModel] pointing to the copied file.
  static Future<FileModel> saveFileToAppDir(File sourceFile) async {
    final directory = await getApplicationSupportDirectory();
    final filesDir = Directory(path.join(directory.path, 'files'));
    if (!await filesDir.exists()) {
      await filesDir.create(recursive: true);
    }

    final basename = path.basename(sourceFile.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final destPath = path.join(filesDir.path, '$timestamp-$basename');

    final copied = await sourceFile.copy(destPath);

    return FileModel(path: copied.path);
  }

  /// Deletes the file at [fileModel.path] from disk, if it exists.
  static Future<void> deleteFileFromDisk(FileModel fileModel) async {
    try {
      final f = File(fileModel.path);
      if (await f.exists()) {
        await f.delete();
      }
    } catch (_) {
      // ignore errors — file may already be removed or path invalid
    }
  }
}
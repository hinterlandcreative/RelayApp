import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as I;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

I.Image _resizeImage(_CopyResizeParams i) {
  return I.copyResize(i.image, width: i.width, height: i.height);
}

class _CopyResizeParams {
  final I.Image image;
  final int height;
  final int width;

  _CopyResizeParams(this.image, this.height, this.width);
}

class ImageService {
  Completer<Directory> _applicationDocumentsDirectory = Completer();

  ImageService() {
    _applicationDocumentsDirectory.complete(getApplicationDocumentsDirectory());
  }

  Future<String> importFile(File image, {String path, bool useRandomFileName = true, bool deleteOldFile = true}) async {
    var directory = await _applicationDocumentsDirectory.future;
    var destination = directory;
    String destinationPath = "";

    String fileName = useRandomFileName 
      ? Uuid().v1() + "." + p.extension(image.path) 
      : p.basename(image.path);

    if(path != null && path.isNotEmpty) {
      destination = Directory(p.join(directory.path, path));
      await destination.create(recursive: true);
      destinationPath = p.join(path, fileName);
    } else {
      destinationPath = fileName;
    }
    var pathToFile = p.join(destination.path, fileName);

    await image.copy(pathToFile);
    
    if(deleteOldFile) {
      await image.delete();
    }

    return destinationPath;
  }

  /// Encodes the image stored in [bytes] as a jpeg and resizes it to [height] and [width].
  /// 
  /// Supply a [path] relative to the application documents directory.
  /// Set either [useRandomFileName] to generate a random filename or supply a [filename].
  /// 
  /// Returns the `path to the file` relative to the apps documents directory.
  Future<String> saveToFile({String path, Uint8List bytes, bool useRandomFileName = true, String filename, int height, int width}) async {
    I.Image image;
    bool isJpeg = false;
    try {
      image = await compute(I.decodeJpg, bytes);
      isJpeg = true;
    } catch (_) {
      image = await compute(I.decodeImage, bytes);
    }

    var start = DateTime.now();
    if(width != null && height != null) {
      image = await compute(_resizeImage, _CopyResizeParams(image, height, width));
    }
    var end = DateTime.now();
    print(start.difference(end));

    if(useRandomFileName) {
      var fileName = Uuid().v1() + ".jpg";
      return await _writeImageToFile(path, fileName, image, isJpeg);
    } else if(filename != null && filename.isNotEmpty) {
      return await _writeImageToFile(path, filename, image, isJpeg);
    }

    throw ArgumentError.notNull("filename");
  }

  /// Supply a relative [pathToFile] and a `File` will be returned with the absolute path to the file.
  Future<File> getImageFile(String pathToFile) async {
    return File(await getImagePath(pathToFile));
  }

  /// Supply a relative [pathTofile] and a `String` will be returned with the absolute path to the file.
  Future<String> getImagePath(String pathToFile) async {
    assert(pathToFile != null);
    assert(pathToFile.isNotEmpty);
    if(pathToFile[0] == p.separator) {
      pathToFile = pathToFile.replaceRange(0, 1, "");
    }
    var directory = await _applicationDocumentsDirectory.future;
    if(pathToFile.startsWith(directory.path)) {
      return pathToFile;
    }
    var pp = p.join(directory.path, pathToFile);
    return pp;
  }

  Future<String> _writeImageToFile(String path, String fileName, I.Image image, bool isJpeg) async {
    var directory = await _applicationDocumentsDirectory.future;
    var destination = directory;
    String destinationPath = "";
    if(path != null && path.isNotEmpty) {
      destination = Directory(p.join(directory.path, path));
      await destination.create(recursive: true);
      destinationPath = p.join(path, fileName);
    } else {
      destinationPath = fileName;
    }
    var pathToFile = p.join(destination.path, fileName);
    List<int> bytes = await compute(I.encodeJpg, image);

    await File(pathToFile).writeAsBytes(bytes);
    return destinationPath;
  }
}
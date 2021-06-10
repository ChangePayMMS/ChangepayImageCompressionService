import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class EsamudaayImageCompressionService {
  static Future<File?> getCompressedImage(
    ImageSource imageSource, {
    String? targetPath,
    int targetSizeInBytes = 150000,
    // 720p and quality 90 is the combination to get file size around 150KB.
    int minHeight = 720,
    int minWidth = 720,
    int quality = 90,
  }) async {
    try {
      final PickedFile? imageFile =
          await ImagePicker().getImage(source: imageSource);

      // If no image was selected then return null;
      if (imageFile == null) return null;

      // get original file size
      final File file = File(imageFile.path);
      final int size = file.lengthSync();

      // if original file size is already less than targetSize then return file.
      if (size <= targetSizeInBytes) return file;

      // if target path is not given, get temp path.
      final Directory dir = targetPath != null
          ? Directory(targetPath)
          : await getTemporaryDirectory();
      // get file name to create unique path for updated file.
      final String fileName = basename(file.path);

      // update file with calculated parameters.
      final File? updatedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        dir.path + "/$fileName.jpeg",
        quality: quality,
        minHeight: minHeight,
        minWidth: minWidth,
        rotate: 0,
      );

      // check new file size if debug mode.
      if (kDebugMode && updatedFile != null) {
        updatedFile.length().then((newSize) {
          debugPrint("updated size => $newSize");
        });
      }
      // return compressed file.
      return updatedFile;
    } catch (e) {
      debugPrint("caught error => $e");
      return null;
    }
  }
}

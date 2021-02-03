import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class EsamudaayImageCompressionService {
  static Future<File> getCompressedImage(
    ImageSource imageSource, {
    String targetPath,
    int targetSizeInBytes = 50000,
  }) async {
    try {
      final PickedFile imageFile =
          await ImagePicker().getImage(source: imageSource);

      // If no image was selected then return null;
      if (imageFile == null) return null;

      // get original file size
      final File file = File(imageFile.path);
      final int size = file.lengthSync();

      // if original file size is already less than targetSize then return file.
      if (size <= targetSizeInBytes) return file;

      // calculate quality ratio to get target file size.
      final int qualityRatio = ((targetSizeInBytes / size) * 100).ceil();

      debugPrint(
          "size => $size , desiredSize => $targetSizeInBytes , getQualityRatio => $qualityRatio , ${file.absolute.path}");

      // if target path is not given, get temp path.
      final Directory dir = targetPath ?? await getTemporaryDirectory();
      // get file name to create unique path for updated file.
      final String fileName = basename(file.path);

      // update file with calculated parameters.
      final File updatedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        dir.path + "/$fileName.jpeg",
        quality: qualityRatio,
        rotate: 0,
      );

      // check new file size if debug mode.
      if (kDebugMode) {
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

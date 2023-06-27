import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AccessPhoneStorage {
  File? _file;


  // singleton
  AccessPhoneStorage._privateConst();
  static final AccessPhoneStorage instance = AccessPhoneStorage._privateConst();

  factory AccessPhoneStorage() {
    return instance;
  }

  File? docFile() => _file;

  Future<bool> saveIntoStorage({required String fileName, required dynamic data, bool writeAsString = false}) async {
    bool result = false;

    try {
      // Check the _directory variable, whether it is still null or not
      // If it's still null, then set the application folder name and create the folder
      // If it's not null but the application folder doesn't exist yet, then set the application folder name and create the folder

      Directory? appDirectory;
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          appDirectory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        if (await _requestPermission(Permission.storage)) {
          appDirectory = await getApplicationDocumentsDirectory();
        }
      }
      // Save the file to the application folder
      if (await appDirectory!.exists()) {
        _file = File("${appDirectory!.path}/$fileName");

        // Save the data
        if (writeAsString) {
          await _file?.writeAsString(data.toString()); // for json, txt
        } else {
          if (data is List<int>) {
            await _file?.writeAsBytes(data); // for pdf, image
          } else {
            debugPrint('Invalid data type for binary file');
          }
        }

        // If _file is not null and _file already exists
        if (_file != null && _file!.existsSync()) {
          result = true;
        } else {
          result = false;
        }
      }
    } catch (e) {
      debugPrint('Failed to save data: $e');
    }

    return result;
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result.isGranted) {
        return true;
      }

      return false;
    }
  }
}

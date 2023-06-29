import 'dart:io';

import 'package:logger/logger.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory> getCustomLogDirectory() async {
  late Directory? directory;

  if (Platform.isAndroid) {
    directory = await getExternalStorageDirectory();
  } else if (Platform.isIOS) {
    directory = await getApplicationSupportDirectory();
  }

  final file = File('${directory?.path}/log.txt');
  if (!await file.exists()) {
    await file.create();
  }
  return Directory(directory!.path);
}

Future<void> writeToLogFile(String message, String type) async {
  final directory = await getCustomLogDirectory();
  final path = '${directory.path}/log.txt';
  final file = File(path);
  await file.writeAsString('${DateTime.now()} : $message\n',
      mode: FileMode.append);
}

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
    printEmojis: true,
    printTime: true,
    noBoxingByDefault: true,
    stackTraceBeginIndex: 0,
  ),
);

customLogger(String logType, String log) {
  switch (logType) {
    case "warn":
      logger.w(log);
      break;
    case "info":
      logger.i(log);
      break;
    case "error":
      logger.e(log);
      break;
    default:
  }
}

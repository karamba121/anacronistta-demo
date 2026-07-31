import 'dart:io';

import 'package:flutter/services.dart';

const _androidChannel = MethodChannel('anacronistta/report_export');

Future<String?> savePdfFile(String fileName, Uint8List bytes) async {
  if (Platform.isWindows) {
    return _saveOnWindows(fileName, bytes);
  }
  if (Platform.isAndroid) {
    return _androidChannel.invokeMethod<String>('savePdf', {
      'fileName': '$fileName.pdf',
      'bytes': bytes,
    });
  }

  throw UnsupportedError(
    'A exportação de PDF não está disponível nesta plataforma.',
  );
}

Future<String?> _saveOnWindows(String fileName, Uint8List bytes) async {
  final userProfile = Platform.environment['USERPROFILE'];
  final downloads = userProfile == null
      ? Directory.current
      : Directory('$userProfile${Platform.pathSeparator}Downloads');
  if (!await downloads.exists()) {
    await downloads.create(recursive: true);
  }

  var destination = File(
    '${downloads.path}${Platform.pathSeparator}$fileName.pdf',
  );
  var copy = 2;
  while (await destination.exists()) {
    destination = File(
      '${downloads.path}${Platform.pathSeparator}$fileName ($copy).pdf',
    );
    copy++;
  }

  await destination.writeAsBytes(bytes, flush: true);
  return destination.path;
}

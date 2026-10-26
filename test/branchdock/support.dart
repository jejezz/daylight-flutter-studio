import 'dart:io';

/// 임시 폴더를 지운다. Windows에서는 git이 파일을 잠깐 잡고 있으면 지우기가 실패하는데, 임시 폴더라서
/// 남겨 둬도 되니 테스트를 실패시키지 않는다 (재시도 뒤에도 안 되면 포기).
Future<void> safeDelete(FileSystemEntity entity) async {
  for (var i = 0; i < 5; i++) {
    try {
      if (entity.existsSync()) await entity.delete(recursive: true);
      return;
    } on FileSystemException {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
  }
}

void safeDeleteSync(FileSystemEntity entity) {
  for (var i = 0; i < 3; i++) {
    try {
      if (entity.existsSync()) entity.deleteSync(recursive: true);
      return;
    } on FileSystemException {
      sleep(const Duration(milliseconds: 150));
    }
  }
}

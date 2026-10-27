import 'package:flutter/material.dart';

import '../studio/file_kind.dart';
import 'app_theme.dart';

/// 파일 트리에 그릴 아이콘 하나: 모양은 현재 아이콘 세트([StudioIcons])에서, 색은 현재 테마의 구문 강조 색에서 가져온다.
/// 그래서 아이콘 모양(둥근·윤곽선·채움)과 색 구성(고대비 포함)을 바꾸면 함께 바뀐다.
typedef FileIcon = ({IconData icon, Color color});

extension FileKindIcons on BuildContext {
  FileIcon fileIcon(FileKind kind) {
    final i = icons;
    final s = syntax;
    final t = tokens;
    final dim = Theme.of(this).colorScheme.onSurfaceVariant;
    return switch (kind) {
      FileKind.dart => (icon: i.code, color: s.title),
      FileKind.package => (icon: i.inventory2, color: s.title),
      FileKind.settings => (icon: i.tune, color: s.attr),
      FileKind.yaml => (icon: i.formatAlignLeft, color: s.number),
      FileKind.json => (icon: i.dataObject, color: s.classType),
      FileKind.document => (icon: i.article, color: s.meta),
      FileKind.image => (icon: i.image, color: s.string),
      FileKind.markup => (icon: i.code, color: s.keyword),
      FileKind.source => (icon: i.code, color: s.builtIn),
      FileKind.script => (icon: i.terminal, color: t.success),
      FileKind.config => (icon: i.settings, color: s.comment),
      FileKind.other => (icon: i.insertDriveFile, color: dim),
    };
  }
}

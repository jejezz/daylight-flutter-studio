import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

/// Markdown을 렌더링해서 보여 준다. 색과 글꼴은 모두 현재 테마를 따르고,
/// 상대 경로 이미지는 문서가 있는 폴더 기준으로 읽는다.
class MarkdownView extends StatelessWidget {
  const MarkdownView({super.key, required this.text, required this.baseDir});

  final String text;

  /// 문서가 있는 폴더 (상대 경로 이미지의 기준).
  final String baseDir;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final scheme = theme.colorScheme;
    final sheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      code: t.editorText.copyWith(backgroundColor: scheme.surfaceContainerHighest, color: scheme.onSurface),
      codeblockPadding: EdgeInsets.all(t.spaceMd),
      codeblockDecoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(t.radius),
      ),
      blockquoteDecoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(left: BorderSide(color: scheme.primary, width: 3)),
      ),
      horizontalRuleDecoration: BoxDecoration(border: Border(top: BorderSide(color: scheme.outlineVariant))),
      tableBorder: TableBorder.all(color: scheme.outlineVariant),
    );
    return Markdown(
      data: text,
      selectable: true,
      styleSheet: sheet,
      padding: EdgeInsets.all(t.spaceLg),
      extensionSet: md.ExtensionSet.gitHubFlavored,
      onTapLink: (_, href, _) => _open(href),
      imageBuilder: (uri, title, alt) => _image(context, uri, alt),
    );
  }

  Widget _image(BuildContext context, Uri uri, String? alt) {
    final fallback = Text(alt == null || alt.isEmpty ? '(이미지를 불러올 수 없습니다)' : '(이미지: $alt)');
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      return Image.network(uri.toString(), errorBuilder: (_, _, _) => fallback);
    }
    final file = File(uri.scheme == 'file' ? uri.toFilePath() : '$baseDir${Platform.pathSeparator}${Uri.decodeComponent(uri.path)}');
    return Image.file(file, errorBuilder: (_, _, _) => fallback);
  }

  /// 웹 주소만 연다. 그 밖의 링크(상대 경로, 파일, 앱 실행 주소)는 열지 않는다.
  static Future<void> _open(String? href) async {
    final uri = href == null ? null : Uri.tryParse(href);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

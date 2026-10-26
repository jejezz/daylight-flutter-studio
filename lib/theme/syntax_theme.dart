/// 구문 강조 색. 테마(라이트/다크)마다 따로 정하고, 편집기가 highlight.js 방식의 이름표에 맞춰 쓴다.
library;

import 'package:flutter/material.dart';

@immutable
class SyntaxTokens extends ThemeExtension<SyntaxTokens> {
  const SyntaxTokens({
    required this.comment,
    required this.keyword,
    required this.string,
    required this.number,
    required this.classType,
    required this.title,
    required this.meta,
    required this.attr,
    required this.builtIn,
    required this.literal,
  });

  final Color comment;
  final Color keyword;
  final Color string;
  final Color number;
  final Color classType;

  /// 함수·메서드·제목 이름.
  final Color title;

  /// 어노테이션, 전처리 지시문, 링크.
  final Color meta;

  /// 속성·변수·태그 이름.
  final Color attr;
  final Color builtIn;
  final Color literal;

  factory SyntaxTokens.forBrightness(Brightness b) {
    if (b == Brightness.dark) {
      return const SyntaxTokens(
        comment: Color(0xFF7F8A99),
        keyword: Color(0xFFD08CF0),
        string: Color(0xFF9ECE6A),
        number: Color(0xFFE0A26B),
        classType: Color(0xFFE6C07B),
        title: Color(0xFF68B5F2),
        meta: Color(0xFF7AA2F7),
        attr: Color(0xFFE5808A),
        builtIn: Color(0xFFE6C07B),
        literal: Color(0xFF56C2CE),
      );
    }
    return const SyntaxTokens(
      comment: Color(0xFF6A737D),
      keyword: Color(0xFF8A2BB0),
      string: Color(0xFF2E7D32),
      number: Color(0xFFB45309),
      classType: Color(0xFF946200),
      title: Color(0xFF1F5FBF),
      meta: Color(0xFF3B5BDB),
      attr: Color(0xFFB4233A),
      builtIn: Color(0xFF946200),
      literal: Color(0xFF00796B),
    );
  }

  /// highlight.js 이름표 → 글자 모양. 이름표에 없는 글자는 기본 색을 쓴다.
  Map<String, TextStyle> highlightTheme({required Color base}) {
    TextStyle c(Color color, {FontStyle? italic, FontWeight? weight}) =>
        TextStyle(color: color, fontStyle: italic, fontWeight: weight);
    return {
      'root': TextStyle(color: base),
      'comment': c(comment),
      'quote': c(comment),
      'doctag': c(keyword),
      'keyword': c(keyword),
      'formula': c(keyword),
      'section': c(title, weight: FontWeight.bold),
      'name': c(attr),
      'selector-tag': c(attr),
      'deletion': c(attr),
      'subst': c(base),
      'literal': c(literal),
      'string': c(string),
      'regexp': c(string),
      'addition': c(string),
      'attribute': c(string),
      'meta-string': c(string),
      'attr': c(attr),
      'variable': c(attr),
      'template-variable': c(attr),
      'type': c(classType),
      'selector-class': c(classType),
      'selector-attr': c(classType),
      'selector-pseudo': c(classType),
      'number': c(number),
      'symbol': c(meta),
      'bullet': c(meta),
      'link': c(meta),
      'meta': c(meta),
      'selector-id': c(meta),
      'title': c(title),
      'title.function_': c(title),
      'title.class_': c(classType),
      'class-title': c(classType),
      'built_in': c(builtIn),
      'emphasis': const TextStyle(fontStyle: FontStyle.italic),
      'strong': const TextStyle(fontWeight: FontWeight.bold),
    };
  }

  @override
  SyntaxTokens copyWith({
    Color? comment,
    Color? keyword,
    Color? string,
    Color? number,
    Color? classType,
    Color? title,
    Color? meta,
    Color? attr,
    Color? builtIn,
    Color? literal,
  }) => SyntaxTokens(
    comment: comment ?? this.comment,
    keyword: keyword ?? this.keyword,
    string: string ?? this.string,
    number: number ?? this.number,
    classType: classType ?? this.classType,
    title: title ?? this.title,
    meta: meta ?? this.meta,
    attr: attr ?? this.attr,
    builtIn: builtIn ?? this.builtIn,
    literal: literal ?? this.literal,
  );

  @override
  SyntaxTokens lerp(SyntaxTokens? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return SyntaxTokens(
      comment: l(comment, other.comment),
      keyword: l(keyword, other.keyword),
      string: l(string, other.string),
      number: l(number, other.number),
      classType: l(classType, other.classType),
      title: l(title, other.title),
      meta: l(meta, other.meta),
      attr: l(attr, other.attr),
      builtIn: l(builtIn, other.builtIn),
      literal: l(literal, other.literal),
    );
  }
}

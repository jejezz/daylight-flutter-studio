import 'package:daylight_workbench/studio/symbol_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const src = '''
import 'package:flutter/material.dart';

abstract class Shape {
  Shape(this.name);
  final String name;

  double area();
  static Shape unit() => Square(1);
  String get label => name;
  set label(String v) {}
}

class Square extends Shape {
  Square(this.side) : super('square');

  @override
  double area() {
    final v = compute(side);
    return helper(v);
  }

  Future<void> save() async {
    await persist(this);
  }
}

mixin Logs on Object {
  void log(String m) {
    print(m);
  }
}

enum Color { red, green }
extension StringX on String {
  String twice() => this + this;
}
typedef Cb = void Function(int);

void main() {
  runApp(const MyApp());
  helper(1);
}

int helper(int x) => x + 1;
Future<List<String>> names<T>() async => [];
// void commented() {}
''';

  List<String> names(Iterable<DartSymbol> s) => [for (final e in s) '${e.container ?? ''}.${e.name}:${e.kind.name}:${e.line}'];

  test('선언을 뽑고 본문 안의 호출은 뽑지 않는다', () {
    final s = extractDartSymbols('a.dart', src);
    expect(
      names(s),
      [
        '.Shape:classType:3',
        'Shape.area:method:7',
        'Shape.unit:method:8',
        'Shape.label:getter:9',
        'Shape.label:setter:10',
        '.Square:classType:13',
        'Square.area:method:17',
        'Square.save:method:22',
        '.Logs:mixin:27',
        'Logs.log:method:28',
        '.Color:enumType:33',
        '.StringX:extension:34',
        'StringX.twice:method:35',
        '.Cb:typedef:37',
        '.main:function:39',
        '.helper:function:44',
        '.names:function:45',
      ],
    );
  });

  test('이름이 있는 줄·열을 가리킨다', () {
    final s = extractDartSymbols('a.dart', src);
    final area = s.firstWhere((e) => e.container == 'Square' && e.name == 'area');
    expect(src.split('\n')[area.line - 1].substring(area.column - 1).startsWith('area'), isTrue);
  });

  test('이름으로 순위를 매기고 정확히 같은 것이 먼저다', () {
    final s = extractDartSymbols('a.dart', src);
    expect(rankSymbols('area', s).first.name, 'area');
    expect(rankSymbols('hlp', s).first.name, 'helper');
    expect(definitionsOf('area', s), hasLength(2));
    expect(definitionsOf('nothing', s), isEmpty);
  });

  test('커서 자리의 낱말', () {
    expect(wordAt('  final v = compute(side);', 14), 'compute');
    expect(wordAt('  final v = compute(side);', 9), 'v');
    expect(wordAt('foo.bar', 3), 'foo');
    expect(wordAt('   ', 1), '');
  });
}

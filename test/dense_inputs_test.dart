import 'package:daylight_flutter_studio/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('데스크톱 테마의 드롭다운·입력칸은 낮다 (기본 56보다 작게)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(StudioPalette.saturn, Brightness.dark),
        home: Scaffold(
          body: Column(
            children: [
              DropdownButtonFormField<String>(
                key: const Key('dropdown'),
                initialValue: 'main',
                items: const [DropdownMenuItem(value: 'main', child: Text('main'))],
                onChanged: (_) {},
              ),
              const TextField(key: Key('field')),
            ],
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byKey(const Key('dropdown'))).height, lessThan(44));
    expect(tester.getSize(find.byKey(const Key('field'))).height, lessThan(44));
  });
}

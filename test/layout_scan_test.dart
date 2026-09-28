// 폰 폭(320·360·390px) × 글자 크기(1·1.3배) × 한/영에서 모든 화면을 그려,
// 가로 넘침(flutter_test가 예외로 실패)과 영문 단어 중간 줄바꿈이 없는지 검사한다.
// (모바일 웹에서 영문 "Department Guide"가 "Departme / nt Guide"로 깨졌던 회귀 방지.)
import 'dart:io';
import 'dart:math';
import 'package:carnegie_departments/departments.dart';
import 'package:carnegie_departments/l10n.dart';
import 'package:carnegie_departments/main.dart';
import 'package:carnegie_departments/new_beginning.dart';
import 'package:carnegie_departments/reference.dart';
import 'package:carnegie_departments/rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ByteData> _f(String p) async =>
    ByteData.sublistView(await File(p).readAsBytes());
final _word = RegExp(r'[A-Za-z0-9]');

/// 화면의 모든 텍스트에서 영문 단어가 줄 경계에서 둘로 쪼개진 곳을 찾는다.
List<String> midWordBreaks(WidgetTester t) {
  final found = <String>[];
  void visit(RenderObject o) {
    if (o is RenderParagraph && o.hasSize && o.size.width > 0) {
      final text = o.text.toPlainText();
      final tp = TextPainter(
        text: o.text,
        textDirection: TextDirection.ltr,
        textScaler: o.textScaler,
        maxLines: o.maxLines,
        textAlign: o.textAlign,
      )..layout(maxWidth: o.size.width + 0.01);
      for (var i = 1; i < text.length; i++) {
        if (!_word.hasMatch(text[i - 1]) || !_word.hasMatch(text[i])) continue;
        final a = tp.getBoxesForSelection(
          TextSelection(baseOffset: i - 1, extentOffset: i),
        );
        final b = tp.getBoxesForSelection(
          TextSelection(baseOffset: i, extentOffset: i + 1),
        );
        if (a.isEmpty || b.isEmpty) continue;
        if ((b.first.top - a.first.top).abs() > 1) {
          final s = max(0, i - 12), e = min(text.length, i + 12);
          found.add('"${text.substring(s, i)}|${text.substring(i, e)}"');
        }
      }
    }
    o.visitChildren(visit);
  }

  for (final e in find.byType(MaterialApp).evaluate()) {
    visit(e.renderObject!);
  }
  return found;
}

void main() {
  setUpAll(() async {
    final l = FontLoader('SUIT');
    for (final w in ['Light', 'Regular', 'Bold', 'ExtraBold']) {
      l.addFont(_f('assets/fonts/SUIT-$w.otf'));
    }
    await l.load();
  });

  final screens = <String, (Widget, Future<void> Function(WidgetTester)?)>{
    'setup': (const SetupScreen(), null),
    'setup_exp': (
      const SetupScreen(),
      (t) => t.tap(find.text(tr('확장 포함', 'With Expansion'))),
    ),
    'result2': (ResultScreen(result: draw(2, Random(1))), null),
    'result2_detail': (
      ResultScreen(result: draw(2, Random(1))),
      (t) => t.tap(find.text(tr('상세', 'Details'))),
    ),
    'result3exp': (ResultScreen(result: drawExpansion(3, Random(1))), null),
    'result3exp_detail': (
      ResultScreen(result: drawExpansion(3, Random(1))),
      (t) => t.tap(find.text(tr('상세', 'Details'))),
    ),
    'disks2': (
      ResultScreen(result: draw(2, Random(1))),
      (t) => t.tap(find.byIcon(Icons.circle)),
    ),
    'disks4': (
      ResultScreen(result: draw(4, Random(1))),
      (t) => t.tap(find.byIcon(Icons.circle)),
    ),
    'solo': (
      ResultScreen(result: draw(2, Random(1))),
      (t) => t.tap(find.byIcon(Icons.person_outline)),
    ),
    'rules': (const RulesSummaryScreen(), null),
    'rules_setup': (
      const RulesSummaryScreen(),
      (t) => t.tap(find.byIcon(Icons.checklist).first),
    ),
    'catalog': (const DeptCatalogScreen(), null),
    'catalog_exp': (
      const DeptCatalogScreen(),
      (t) => t.tap(find.text(tr('확장', 'Expansion'))),
    ),
    'organize': (
      const DeptCatalogScreen(),
      (t) => t.tap(find.byIcon(Icons.info_outline)),
    ),
    'icons': (const IconReferenceScreen(), null),
    'newbeg': (const NewBeginningScreen(), null),
  };
  for (final lang in AppLang.values) {
    for (final w in [320.0, 360.0, 390.0]) {
      for (final s in [1.0, 1.3]) {
        for (final entry in screens.entries) {
          testWidgets('${lang.name} $w x$s ${entry.key}', (t) async {
            appLang.value = lang;
            t.view.devicePixelRatio = 1;
            t.view.physicalSize = Size(w, 6000);
            await t.pumpWidget(
              MaterialApp(
                theme: ThemeData(fontFamily: 'SUIT'),
                builder: (c, child) => MediaQuery(
                  data: MediaQuery.of(
                    c,
                  ).copyWith(textScaler: TextScaler.linear(s)),
                  child: child!,
                ),
                home: entry.value.$1,
              ),
            );
            await t.pumpAndSettle();
            if (entry.value.$2 != null) {
              await entry.value.$2!(t);
              await t.pumpAndSettle();
            }
            expect(midWordBreaks(t), isEmpty);
          });
        }
      }
    }
  }
  // Department detail sheets, every department.
  for (final lang in AppLang.values) {
    for (final w in [320.0, 360.0]) {
      testWidgets('${lang.name} $w detail sheets', (t) async {
        appLang.value = lang;
        t.view.devicePixelRatio = 1;
        t.view.physicalSize = Size(w, 2000);
        await t.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'SUIT'),
            home: ResultScreen(result: drawExpansion(3, Random(1))),
          ),
        );
        await t.pumpAndSettle();
        await t.tap(find.text(tr('상세', 'Details')));
        await t.pumpAndSettle();
        expect(midWordBreaks(t), isEmpty);
      });
    }
  }
}

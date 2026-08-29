import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:carnegie_departments/departments.dart';
import 'package:carnegie_departments/main.dart';

void main() {
  test('draw removes the correct number of tiles per player count', () {
    for (final entry in removalByPlayerCount.entries) {
      final result = draw(entry.key, Random(42));
      final removed =
          result.removed.values.fold<int>(0, (sum, c) => sum + c);
      expect(removed, entry.value);
      expect(result.removed.values.every((c) => c >= 1 && c <= 2), isTrue);
      expect(result.totalKept, 32 - entry.value);
    }
  });

  testWidgets('setup screen renders and can draw', (tester) async {
    await tester.pumpWidget(const CarnegieApp());
    expect(find.text('게임 준비'), findsOneWidget);
    expect(find.text('부서 타일 뽑기'), findsOneWidget);

    await tester.tap(find.text('1-2인'));
    await tester.pump();
    await tester.tap(find.text('부서 타일 뽑기'));
    await tester.pumpAndSettle();
    expect(find.text('상자에 되돌릴 타일'), findsWidgets);
    expect(find.text('테이블에 놓을 타일'), findsWidgets);
  });
}

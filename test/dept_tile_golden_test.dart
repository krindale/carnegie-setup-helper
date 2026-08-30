import 'dart:io';

import 'package:carnegie_departments/carbon.dart';
import 'package:carnegie_departments/dept_tile.dart';
import 'package:carnegie_departments/departments.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ByteData> _font(String path) async {
  return ByteData.sublistView(await File(path).readAsBytes());
}

void main() {
  // testWidgets 본문은 FakeAsync 존이라 실제 파일 I/O가 완료되지 않으므로
  // 폰트는 setUpAll에서 로드한다.
  setUpAll(() async {
    final loader = FontLoader('SUIT');
    for (final weight in ['Thin', 'Light', 'Regular', 'Bold', 'ExtraBold']) {
      loader.addFont(_font('assets/fonts/SUIT-$weight.otf'));
    }
    await loader.load();

    // Material 아이콘 폰트는 테스트 번들에 없으므로 SDK 캐시에서 로드한다.
    final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
    final iconLoader = FontLoader('MaterialIcons')
      ..addFont(
        _font(
          '$flutterRoot/bin/cache/artifacts/material_fonts/'
          'MaterialIcons-Regular.otf',
        ),
      );
    await iconLoader.load();
  });

  testWidgets('부서 타일 1번 재창작 시안 골든', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: CarbonColors.pageBackground,
          body: Center(
            child: SizedBox(width: 400, child: DeptTile(dept: departments[0])),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(DeptTile),
      matchesGoldenFile('goldens/dept_tile_01.png'),
    );
  });

  testWidgets('유형 4색 시안 골든 (인사/경영/건설/연구개발)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 810));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: CarbonColors.pageBackground,
          body: Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // 유형별 대표: 1 인사, 5 경영, 9 건설, 13 연구개발.
                for (final n in [1, 5, 9, 13])
                  SizedBox(
                    width: 400,
                    child: DeptTile(dept: departments[n - 1]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(Wrap),
      matchesGoldenFile('goldens/dept_tile_types.png'),
    );
  });

  testWidgets('16종 전체 시트 골든', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    await tester.binding.setSurfaceSize(const Size(1460, 1270));
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: CarbonColors.pageBackground,
          body: Center(
            child: Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final d in departments)
                  SizedBox(width: 340, child: DeptTile(dept: d)),
              ],
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(Wrap),
      matchesGoldenFile('goldens/dept_tile_all.png'),
    );
  });
}

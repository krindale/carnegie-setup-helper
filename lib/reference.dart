import 'package:flutter/material.dart';

import 'carbon.dart';
import 'departments.dart';

// ---------------------------------------------------------------------------
// Department catalog screen (부서 도감)
// ---------------------------------------------------------------------------

class DeptCatalogScreen extends StatelessWidget {
  const DeptCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CarbonSpacing.s5,
                  ),
                  child: TopBar(onBack: () => Navigator.of(context).pop()),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(CarbonSpacing.s5),
                    children: [
                      Text('부서 도감', style: CarbonText.heading05),
                      const SizedBox(height: CarbonSpacing.s3),
                      Text(
                        '기본판 부서 16종 — 종류별 4개씩, 각 2장씩 들어 있습니다. '
                        '4·8·12·16번 부서는 색이 다르며 지속 효과를 제공합니다.',
                        style: CarbonText.body01.copyWith(
                          color: CarbonColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: CarbonSpacing.s5),
                      for (final type in DeptType.values) ...[
                        Container(
                          margin: const EdgeInsets.only(top: CarbonSpacing.s4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: CarbonSpacing.s4,
                            vertical: CarbonSpacing.s3,
                          ),
                          decoration: const BoxDecoration(
                            color: CarbonColors.layer01,
                            border: Border(
                              left: BorderSide(
                                color: CarbonColors.interactive,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/reficons/i0${DeptType.values.indexOf(type) + 1}.png',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: CarbonSpacing.s3),
                              Text(type.ko, style: CarbonText.heading02),
                              const SizedBox(width: CarbonSpacing.s3),
                              Text(type.en, style: CarbonText.helperText01),
                            ],
                          ),
                        ),
                        const SizedBox(height: CarbonSpacing.s4),
                        for (final d in departments.where(
                          (d) => d.type == type,
                        )) ...[
                          _CatalogRow(dept: d),
                          const SizedBox(height: CarbonSpacing.s4),
                        ],
                      ],
                      const SizedBox(height: CarbonSpacing.s7),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CatalogRow extends StatelessWidget {
  const _CatalogRow({required this.dept});

  final Department dept;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CarbonColors.background,
        border: Border.all(color: CarbonColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(CarbonSpacing.s5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageWidth = constraints.maxWidth * 0.56 > 240
              ? 240.0
              : constraints.maxWidth * 0.56;
          // 부서 타이틀 → 부서 이미지 → 부서 설명 순서의 세로 배치.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      '${dept.number}. ${dept.ko}',
                      style: CarbonText.heading03.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (dept.ongoing)
                    const Padding(
                      padding: EdgeInsets.only(left: CarbonSpacing.s2),
                      child: CarbonTag(
                        text: '지속 효과',
                        bg: CarbonColors.tagAccentBg,
                        fg: CarbonColors.tagAccentText,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(dept.en, style: CarbonText.helperText01),
              const SizedBox(height: CarbonSpacing.s4),
              Center(
                child: Image.asset(
                  dept.image,
                  width: imageWidth,
                  cacheWidth: 500,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: CarbonSpacing.s5),
              Text(dept.rule, style: CarbonText.body01.copyWith(height: 1.6)),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Icon reference screen (아이콘 참조표, 규칙서 20쪽) — legend-style grid of
// individual icons with text descriptions.
// ---------------------------------------------------------------------------

class _RefItem {
  const _RefItem(this.icon, this.label);
  final int icon; // reficons/iNN.png
  final String label;
}

class _RefSection {
  const _RefSection(this.title, this.items);
  final String title;
  final List<_RefItem> items;
}

const _refSections = <_RefSection>[
  _RefSection('부서 종류', [
    _RefItem(1, '인사'),
    _RefItem(2, '경영'),
    _RefItem(3, '건설'),
    _RefItem(4, '연구&개발'),
  ]),
  _RefSection('파견 칸', [
    _RefItem(5, '파견 칸에 올라간 직원'),
    _RefItem(6, '파견 칸에서 직원 1명 가져오기 (로비로 되돌아감)'),
    _RefItem(7, '파견 칸에서 직원 1명 이상 가져오기 (로비로 되돌아감)'),
    _RefItem(8, '파견 칸에 직원 1명 놓기'),
  ]),
  _RefSection('직원', [
    _RefItem(9, '활성화된 직원'),
    _RefItem(10, '비활성화된 직원'),
    _RefItem(11, '공급처에서 새 직원 1명 얻어 로비로 보내기'),
    _RefItem(12, '로비에 도착한 직원'),
    _RefItem(13, '직원 1명을 회사판에서 1칸 이동 (직원은 비활성화됨)'),
  ]),
  _RefSection('부서', [
    _RefItem(14, '부서'),
    _RefItem(15, '활성화된 직원이 있는 부서'),
    _RefItem(16, '비활성화된 직원이 있는 부서'),
    _RefItem(17, '이 부서로 직원 1명 이동시키기'),
    _RefItem(18, '빈칸에 새로운 부서 1개 조직하기'),
    _RefItem(19, '비활성 직원이 있는 빈칸에 새 부서 1개 조직하기'),
  ]),
  _RefSection('기부', [
    _RefItem(20, '기부'),
    _RefItem(21, '한 번 기부하기'),
    _RefItem(22, '다른 플레이어의 디스크 위에 기부 디스크 1개 놓기'),
  ]),
  _RefSection('지도', [
    _RefItem(23, '지도 위 건설 디스크'),
    _RefItem(24, '소도시 칸 위 건설 디스크'),
    _RefItem(25, '대도시 연결 점수'),
  ]),
  _RefSection('수입', [
    _RefItem(26, '운송수단 트랙 위 현재 칸에서 수입 받기'),
    _RefItem(27, '프로젝트 탭 위 공개된 칸에서 수입 받기'),
    _RefItem(28, '상품 큐브 1개 또는 \$3 선택하기'),
    _RefItem(29, '새로운 직원 1명 또는 \$1 선택하기'),
    _RefItem(30, '기부마다 승점 제한을 3만큼 높이기 (최대)'),
  ]),
  _RefSection('승점', [_RefItem(31, '즉시 얻는 승점'), _RefItem(32, '게임 종료 시 얻는 승점')]),
  _RefSection('프로젝트 종류', [
    _RefItem(33, '사회 기반시설'),
    _RefItem(34, '산업'),
    _RefItem(35, '상업'),
    _RefItem(36, '주거'),
  ]),
  _RefSection('연구', [
    _RefItem(37, '소비할 수 있는 연구 점수'),
    _RefItem(38, '연구 점수 비용'),
    _RefItem(39, '연구 점수 비용 할인'),
  ]),
  _RefSection('운송수단 트랙', [
    _RefItem(40, '운송수단 트랙'),
    _RefItem(41, '수레'),
    _RefItem(42, '마차'),
    _RefItem(43, '철도'),
  ]),
  _RefSection('상품&돈', [
    _RefItem(44, '돈 받기'),
    _RefItem(45, '돈 소비하기'),
    _RefItem(46, '상품 큐브 1개 받기'),
    _RefItem(47, '상품 큐브 1개 소비하기'),
  ]),
];

class IconReferenceScreen extends StatelessWidget {
  const IconReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CarbonSpacing.s5,
                  ),
                  child: TopBar(onBack: () => Navigator.of(context).pop()),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(CarbonSpacing.s5),
                    children: [
                      Text('아이콘 참조표', style: CarbonText.heading05),
                      const SizedBox(height: CarbonSpacing.s5),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final twoCols = constraints.maxWidth >= 640;
                          if (!twoCols) {
                            return Column(
                              children: [
                                for (final s in _refSections)
                                  _RefSectionCard(section: s),
                              ],
                            );
                          }
                          // Masonry: fill the shorter of two columns.
                          final left = <_RefSection>[];
                          final right = <_RefSection>[];
                          var lh = 0.0, rh = 0.0;
                          for (final s in _refSections) {
                            final h = 56.0 + s.items.length * 64.0;
                            if (lh <= rh) {
                              left.add(s);
                              lh += h;
                            } else {
                              right.add(s);
                              rh += h;
                            }
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    for (final s in left)
                                      _RefSectionCard(section: s),
                                  ],
                                ),
                              ),
                              const SizedBox(width: CarbonSpacing.s5),
                              Expanded(
                                child: Column(
                                  children: [
                                    for (final s in right)
                                      _RefSectionCard(section: s),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: CarbonSpacing.s7),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RefSectionCard extends StatelessWidget {
  const _RefSectionCard({required this.section});

  final _RefSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: CarbonSpacing.s5),
      decoration: BoxDecoration(
        color: CarbonColors.background,
        border: Border.all(color: CarbonColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CarbonSpacing.s5,
              CarbonSpacing.s5,
              CarbonSpacing.s5,
              6,
            ),
            child: Text(
              section.title,
              style: CarbonText.heading02.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          for (final (i, item) in section.items.indexed) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.only(left: 107),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE4E6E7),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                CarbonSpacing.s5,
                10,
                CarbonSpacing.s5,
                i == section.items.length - 1 ? CarbonSpacing.s5 : 10,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 75,
                    child: Image.asset(
                      'assets/reficons/i${item.icon.toString().padLeft(2, '0')}.png',
                      cacheWidth: 225,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  const SizedBox(width: CarbonSpacing.s5),
                  Expanded(
                    child: Text(
                      item.label,
                      style: CarbonText.body02.copyWith(height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

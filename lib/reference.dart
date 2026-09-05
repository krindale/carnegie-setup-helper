import 'package:flutter/material.dart';

import 'carbon.dart';
import 'departments.dart';
import 'dept_tile.dart';

// ---------------------------------------------------------------------------
// Department catalog screen (부서 도감)
// ---------------------------------------------------------------------------

class DeptCatalogScreen extends StatefulWidget {
  const DeptCatalogScreen({super.key});

  @override
  State<DeptCatalogScreen> createState() => _DeptCatalogScreenState();
}

class _DeptCatalogScreenState extends State<DeptCatalogScreen> {
  /// 0 = 기본판(1~16), 1 = 확장(17~32).
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final shown = _tab == 0 ? departments : expansionDepartments;
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
                  child: TopBar(
                    onBack: () => Navigator.of(context).pop(),
                    actions: [
                      TopIconButton(
                        icon: Icons.info_outline,
                        tooltip: '부서 조직 방법',
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          backgroundColor: CarbonColors.background,
                          shape: const RoundedRectangleBorder(),
                          constraints: const BoxConstraints(maxWidth: 672),
                          isScrollControlled: true,
                          builder: (context) => const _OrganizeGuideSheet(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(CarbonSpacing.s5),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('부서 도감', style: CarbonText.heading05),
                          ),
                          CarbonContentSwitcher(
                            labels: const ['기본판', '확장'],
                            selected: _tab,
                            onChanged: (i) => setState(() => _tab = i),
                          ),
                        ],
                      ),
                      const SizedBox(height: CarbonSpacing.s3),
                      Text(
                        _tab == 0
                            ? '기본판 부서 16종(1~16번) — 종류별 4개씩, 각 2장씩 '
                                  '들어 있습니다. 4·8·12·16번 부서는 색이 다르며 '
                                  '지속 효과를 제공합니다.'
                            : '확장 부서 16종(17~32번) — 종류별 4개씩, 각 2장씩 '
                                  '들어 있습니다. 지속 효과 부서와 게임 종료 시 '
                                  '득점하는 부서가 있습니다.',
                        style: CarbonText.body01.copyWith(
                          color: CarbonColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: CarbonSpacing.s3),
                      for (final type in DeptType.values) ...[
                        Container(
                          margin: const EdgeInsets.only(top: CarbonSpacing.s4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: CarbonSpacing.s4,
                            vertical: CarbonSpacing.s3,
                          ),
                          decoration: BoxDecoration(
                            color: CarbonColors.layer01,
                            border: Border(
                              // 타일 넘버 플레이트와 같은 유형 컬러.
                              left: BorderSide(
                                color: deptTypeColorOf(type),
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
                        for (final d in shown.where((d) => d.type == type)) ...[
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

/// 부서 조직 방법·비용 안내 모달 시트
/// (근거: 규칙서 10쪽 "전략 기획", 6쪽 4.2 활성화 비용 — UI에는 미표기).
class _OrganizeGuideSheet extends StatelessWidget {
  const _OrganizeGuideSheet();

  static const _rows = <(IconData, String)>[
    (
      Icons.work_outline,
      '경영 행동에서 "전략 기획" 부서의 활성화된 직원 1명당 새 부서 1개를 '
          '조직할 수 있습니다.',
    ),
    (
      Icons.inventory_2_outlined,
      '비용: 상품 큐브 2개 — 회사판의 아무 빈칸에 배치. 직원이 1명 이상 '
          '있는 빈칸이면 큐브 1개만 지불합니다.',
    ),
    (
      Icons.looks_one_outlined,
      '첫 번째로 조직하는 부서는 게임 준비(10번)에서 선택해 둔 부서여야 '
          '합니다.',
    ),
    (Icons.block, '같은 부서는 한 회사에 2개 이상 둘 수 없습니다.'),
    (
      Icons.paid_outlined,
      '타일 사무공간 아래의 금액은 조직 비용이 아니라, 라운드 종료 시 그 '
          '자리 직원을 활성화할 때 내는 비용입니다.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CarbonSpacing.s6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.add_business_outlined,
                  size: 20,
                  color: CarbonColors.textSecondary,
                ),
                const SizedBox(width: CarbonSpacing.s3),
                Expanded(child: Text('부서 조직 방법', style: CarbonText.heading03)),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(CarbonSpacing.s2),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: CarbonColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: CarbonSpacing.s5),
            for (final (icon, text) in _rows)
              Padding(
                padding: const EdgeInsets.only(bottom: CarbonSpacing.s3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        icon,
                        size: 16,
                        color: CarbonColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: CarbonSpacing.s3),
                    Expanded(
                      child: Text(
                        text,
                        style: CarbonText.body01.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
          ],
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
      // 플레이트+이름 → 괘선 → 엠블럼 → 효과 바 → 설명. 타일과 같은 부품을
      // 화면 폭에 맞게 직접 배치한다.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DeptNumberPlate(dept: dept, size: 40),
              const SizedBox(width: CarbonSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dept.ko,
                      style: CarbonText.heading03.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(dept.en, style: CarbonText.helperText01),
                  ],
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
              if (dept.endgame)
                const Padding(
                  padding: EdgeInsets.only(left: CarbonSpacing.s2),
                  child: CarbonTag(
                    text: '게임 종료',
                    bg: CarbonColors.tagAccentBg,
                    fg: CarbonColors.tagAccentText,
                  ),
                ),
            ],
          ),
          const SizedBox(height: CarbonSpacing.s4),
          DeptDoubleRule(dept: dept),
          const SizedBox(height: CarbonSpacing.s5),
          Center(child: DeptEmblem(dept: dept, scale: 0.85)),
          const SizedBox(height: CarbonSpacing.s5),
          DeptEffectBar(dept: dept, scale: 0.9),
          const SizedBox(height: CarbonSpacing.s5),
          Text(dept.rule, style: CarbonText.body01.copyWith(height: 1.6)),
        ],
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

// 참조표 강조색 — 규칙서 20쪽의 구조(오버라인·이중 밑줄·잔점선)는 따르되
// 색은 앱 팔레트로 통일 (사용자 확정).
const _refAccent = CarbonColors.interactive;
const _refDot = CarbonColors.borderStrong;

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
                      // 규칙서 20쪽의 표제 구조: 제목 + 이중 밑줄.
                      Text(
                        '아이콘 참조표',
                        style: CarbonText.heading05.copyWith(color: _refAccent),
                      ),
                      const SizedBox(height: CarbonSpacing.s3),
                      Container(height: 1.4, color: _refAccent),
                      const SizedBox(height: 2.5),
                      Container(height: 1.4, color: _refAccent),
                      const SizedBox(height: CarbonSpacing.s5),
                      // 열 묶음 순서는 규칙서 그대로, 항목 사이 선 없음,
                      // 열 사이 잔점선. 새 단은 오버라인으로 시작한다.
                      Container(
                        decoration: BoxDecoration(
                          color: CarbonColors.background,
                          border: Border.all(color: CarbonColors.borderSubtle),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: CarbonSpacing.s3,
                          vertical: CarbonSpacing.s5,
                        ),
                        child: Column(
                          children: [
                            for (final (i, row) in _refRows.indexed) ...[
                              if (i > 0)
                                const SizedBox(height: CarbonSpacing.s6),
                              _RefPairRow(left: row.$1, right: row.$2),
                            ],
                          ],
                        ),
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

/// 규칙서 20쪽의 열 묶음 순서 그대로 두 열씩 짝지어 배치한다.
final _refRows = <(List<_RefSection>, List<_RefSection>)>[
  ([_refSections[0]], [_refSections[1]]),
  ([_refSections[2]], [_refSections[3]]),
  ([_refSections[4], _refSections[5]], [_refSections[6], _refSections[7]]),
  ([_refSections[8], _refSections[9]], [_refSections[10], _refSections[11]]),
];

/// 두 열 스트립 + 가운데 점선. (IntrinsicHeight는 이미지 고유 높이를 열 폭
/// 기준으로 과대 계산하므로 점선은 Stack 위에 그린다.)
class _RefPairRow extends StatelessWidget {
  const _RefPairRow({required this.left, required this.right});

  final List<_RefSection> left;
  final List<_RefSection> right;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _VDashPainter())),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _RefStrip(sections: left)),
            const SizedBox(width: CarbonSpacing.s4),
            Expanded(child: _RefStrip(sections: right)),
          ],
        ),
      ],
    );
  }
}

/// 세로 스트립: 제목(밑줄) 아래로 아이콘·설명을 촘촘히 쌓는다.
/// 규칙서처럼 항목 사이에 구분선을 두지 않는다.
class _RefStrip extends StatelessWidget {
  const _RefStrip({required this.sections});

  final List<_RefSection> sections;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, s) in sections.indexed) ...[
          // 규칙서의 열 머리: 굵은 오버라인 + 진한 제목.
          Padding(
            padding: EdgeInsets.fromLTRB(
              CarbonSpacing.s3,
              i == 0 ? 0 : CarbonSpacing.s6,
              CarbonSpacing.s3,
              CarbonSpacing.s2,
            ),
            child: Column(
              children: [
                Container(height: 3.5, color: _refAccent),
                const SizedBox(height: CarbonSpacing.s3),
                Text(
                  s.title,
                  textAlign: TextAlign.center,
                  style: CarbonText.heading01,
                ),
              ],
            ),
          ),
          for (final item in s.items)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CarbonSpacing.s3,
                CarbonSpacing.s3,
                CarbonSpacing.s3,
                CarbonSpacing.s2,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 60,
                    child: Image.asset(
                      'assets/reficons/i${item.icon.toString().padLeft(2, '0')}.png',
                      cacheWidth: 180,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  const SizedBox(height: CarbonSpacing.s2),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: CarbonText.label01.copyWith(
                      color: CarbonColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

/// 규칙서의 열 구분 잔점선 (세로, 가운데).
class _VDashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _refDot;
    final x = size.width / 2;
    for (var y = 2.0; y < size.height; y += 6) {
      canvas.drawCircle(Offset(x, y), 0.9, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

import 'carbon.dart';
import 'departments.dart';
import 'dept_tile.dart';

// ---------------------------------------------------------------------------
// 게임 룰 요약 화면 — 근거: 규칙서 6–13쪽 (라운드 진행 7쪽, 이벤트 8쪽,
// 행동 9–12쪽, 활성화·종료·승점 13쪽). UI에는 쪽수를 노출하지 않는다.
// ---------------------------------------------------------------------------

class RulesSummaryScreen extends StatelessWidget {
  const RulesSummaryScreen({super.key});

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
                  child: TopBar(
                    onBack: () => Navigator.of(context).pop(),
                    actions: [
                      TopIconButton(
                        icon: Icons.checklist,
                        tooltip: '초기 세팅',
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          backgroundColor: CarbonColors.background,
                          shape: const RoundedRectangleBorder(),
                          constraints: BoxConstraints(
                            maxWidth: 672,
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.85,
                          ),
                          isScrollControlled: true,
                          builder: (context) => const _SetupGuideSheet(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(CarbonSpacing.s5),
                    children: [
                      Text('게임 룰 요약', style: CarbonText.heading05),
                      const SizedBox(height: CarbonSpacing.s3),
                      Text(
                        '20라운드 동안 회사를 운영해 가장 높은 승점을 얻는 '
                        '플레이어가 승리합니다.',
                        style: CarbonText.body02.copyWith(
                          color: CarbonColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: CarbonSpacing.s5),
                      const _SectionHeader(title: '라운드 진행', subtitle: '4단계'),
                      _card([
                        _numRow(
                          1,
                          '타임라인 선택',
                          '시작 플레이어가 인사·경영·건설·연구개발 중 하나를 골라 타임라인 마커를 놓습니다.',
                        ),
                        _numRow(
                          2,
                          '이벤트',
                          '마커가 놓인 칸의 이벤트(수입 또는 기부)가 모든 플레이어에게 발생합니다.',
                        ),
                        _numRow(
                          3,
                          '부서 사용',
                          '시작 플레이어부터 시계 방향으로, 선택된 행동과 같은 종류의 자기 부서들을 사용합니다. 각 부서는 활성화된 직원 1명당 1번씩 쓸 수 있습니다.',
                        ),
                        _numRow(
                          4,
                          '직원 활성화·라운드 종료',
                          '사무공간에 표시된 비용을 내고 직원을 활성화한 뒤, 행동 마커를 오른쪽으로 1칸 전진시킵니다.',
                        ),
                      ]),
                      const _SectionHeader(title: '이벤트'),
                      _card([
                        _iconRow(
                          Icons.payments_outlined,
                          '수입 받기',
                          '활성화된 파견 지역의 직원을 원하는 만큼 로비로 복귀시키고, 복귀한 직원마다 운송 수입을 받습니다. 1명 이상 복귀시켰다면 지어 둔 프로젝트 수입도 받습니다(라운드당 1번).',
                        ),
                        _iconRow(
                          Icons.volunteer_activism_outlined,
                          '기부하기',
                          '기부 차트의 빈칸에 디스크를 놓습니다. 첫 기부는 \$5이고, 이후 기부할 때마다 \$5씩 비싸집니다(\$10, \$15…).',
                        ),
                      ]),
                      const _SectionHeader(title: '4가지 행동'),
                      _card([
                        _typeRow(
                          DeptType.hr,
                          '활성화된 인사 직원 1명당 직원 이동 3회(항상 최소 3회). 가로·세로로만 이동하며, 활성화된 직원은 이동하면 비활성화됩니다.',
                        ),
                        _typeRow(
                          DeptType.management,
                          '"상업과 재무"로 돈·상품을 얻고, "전략 기획"으로 새 부서를 조직합니다(큐브 2개, 직원이 있는 빈칸이면 1개).',
                        ),
                        _typeRow(
                          DeptType.construction,
                          '직원 1명을 파견 보내고 큐브 1~2개를 지불해 그 지역에 프로젝트를 짓습니다. 소도시에 지으면 즉시 운송 수입을 받습니다.',
                        ),
                        _typeRow(
                          DeptType.rnd,
                          '활성화된 직원마다 연구 점수를 얻어 프로젝트 탭이나 운송 트랙을 전진시킵니다. 남은 점수는 차례가 끝나면 사라집니다.',
                        ),
                      ]),
                      const _SectionHeader(title: '꼭 기억할 것'),
                      _card([
                        _iconRow(
                          Icons.paid_outlined,
                          null,
                          '직원 활성화 비용은 사무공간 아래 금액이며, 라운드 종료 시에만 활성화할 수 있습니다.',
                        ),
                        _iconRow(
                          Icons.outbound_outlined,
                          null,
                          '파견 중인 직원은 활성화된 것으로 치지 않습니다.',
                        ),
                        _iconRow(
                          Icons.currency_exchange,
                          null,
                          '상품 큐브는 언제든 개당 \$1에 팔 수 있습니다.',
                        ),
                        _iconRow(
                          Icons.swap_horiz,
                          null,
                          '(3·4인) 행동 선택 타일로 선택된 것과 다른 행동을 게임당 1번 할 수 있습니다. 쓰지 않으면 종료 시 3점입니다.',
                        ),
                      ]),
                      const _SectionHeader(title: '게임 종료 승점'),
                      _card([
                        _iconRow(
                          Icons.person,
                          null,
                          '활성화된 직원 1명당 1점 (파견 나간 직원과 영구 직원은 제외).',
                        ),
                        _iconRow(
                          Icons.grid_view,
                          null,
                          '조직한 부서당 2~3점 (회사판 최상단 행에 놓인 부서는 3점).',
                        ),
                        _iconRow(
                          Icons.trending_up,
                          null,
                          '프로젝트 탭 전진 — 주거 최대 6점 · 상업 9점 · 산업 12점 · 사회 기반시설 15점.',
                        ),
                        _iconRow(
                          Icons.route_outlined,
                          null,
                          '대도시(뉴욕·시카고·뉴올리언스·샌프란시스코) 연결 최대 36점, 지은 프로젝트마다 도시별 0~3점.',
                        ),
                        _iconRow(
                          Icons.volunteer_activism_outlined,
                          null,
                          '기부당 최대 12점.',
                        ),
                      ]),
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

  Widget _card(List<Widget> rows) {
    return Container(
      margin: const EdgeInsets.only(bottom: CarbonSpacing.s4),
      decoration: BoxDecoration(
        color: CarbonColors.background,
        border: Border.all(color: CarbonColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(CarbonSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, row) in rows.indexed) ...[
            if (i > 0) const SizedBox(height: CarbonSpacing.s4),
            row,
          ],
        ],
      ),
    );
  }

  Widget _numRow(int n, String title, String text) {
    return _row(
      leading: Container(
        width: 26,
        height: 26,
        color: CarbonColors.layer01,
        alignment: Alignment.center,
        child: Text('$n', style: CarbonText.heading01.copyWith(fontSize: 13)),
      ),
      title: title,
      text: text,
    );
  }

  Widget _iconRow(IconData icon, String? title, String text) {
    return _row(
      leading: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icon(icon, size: 18, color: CarbonColors.textSecondary),
      ),
      title: title,
      text: text,
    );
  }

  /// 유형 칩 — 모두 2글자 폭(연구개발은 두 줄)이라 자연히 같은 크기가 되고,
  /// 상하좌우 여백을 비슷하게 맞춘다.
  Widget _typeRow(DeptType type, String text) {
    return _row(
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        color: deptTypeColorOf(type),
        child: Text(
          type == DeptType.rnd ? '연구\n개발' : type.ko,
          textAlign: TextAlign.center,
          style: CarbonText.label01.copyWith(
            color: CarbonColors.textOnColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      title: null,
      text: text,
    );
  }

  Widget _row({
    required Widget leading,
    required String? title,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leading,
        const SizedBox(width: CarbonSpacing.s4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(title, style: CarbonText.heading01),
                const SizedBox(height: 2),
              ],
              Text(text, style: CarbonText.body01.copyWith(height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}

/// 초기 세팅(게임 준비) 요약 모달 시트 (근거: 규칙서 4–5쪽 1~12번 —
/// UI에는 미표기). 부서 제외(4번)와 중립 디스크(9번)는 이 앱이 대신한다.
class _SetupGuideSheet extends StatelessWidget {
  const _SetupGuideSheet();

  static const _steps = <String>[
    '타임라인 타일 무작위 4개 + 시작·종료 타일',
    '행동 마커 4개를 시작 위치에',
    '부서 타일 제외\n2인 16 · 3인 8 · 4인 4 (이 앱이 대신)',
    '각자: 큐브 4 + \$12 · 회사판 + 탭 4\n직원 10(5 세움, 5 로비, 5 예비)',
    '각자 디스크 배치: 승점 0칸 · 운송 트랙 4곳 첫 칸\n주거·상업·산업 탭 '
        '1개씩',
    '시작 플레이어 정하기',
    '행동 선택 타일\n4인 전원 · 3인 셋째만 · 2인 없음',
    '중립 디스크\n2인 18 · 3인 9 · 4인 생략 (이 앱이 대신)',
    '반시계로: 주거 디스크 1개 + 첫 부서 타일 고르기',
    '시계로: 직원 최대 6회 이동 후 활성화',
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
                  Icons.checklist,
                  size: 20,
                  color: CarbonColors.textSecondary,
                ),
                const SizedBox(width: CarbonSpacing.s3),
                Expanded(child: Text('초기 세팅', style: CarbonText.heading03)),
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
            for (final (i, step) in _steps.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: CarbonSpacing.s4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      color: CarbonColors.layer01,
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        style: CarbonText.heading01.copyWith(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: CarbonSpacing.s4),
                    Expanded(
                      child: Text(
                        step,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: CarbonSpacing.s4,
        bottom: CarbonSpacing.s4,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: CarbonSpacing.s4,
        vertical: CarbonSpacing.s3,
      ),
      decoration: const BoxDecoration(
        color: CarbonColors.layer01,
        border: Border(
          left: BorderSide(color: CarbonColors.interactive, width: 4),
        ),
      ),
      child: Row(
        children: [
          Text(title, style: CarbonText.heading02),
          if (subtitle != null) ...[
            const SizedBox(width: CarbonSpacing.s3),
            Text(subtitle!, style: CarbonText.helperText01),
          ],
        ],
      ),
    );
  }
}

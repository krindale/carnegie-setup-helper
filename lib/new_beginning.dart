import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'carbon.dart';

// ---------------------------------------------------------------------------
// 확장 #1 "새로운 시작" 입찰 시트 개인 계산기 (확장 룰북 1쪽).
// 실물 시트의 다섯 줄을 그대로 옮겼다: 선 플레이어 입찰(자유 금액) ·
// 상품 큐브 · 로비 직원 · 승점 · 준비 이동. 총합(입찰 포함)은 $50를 넘을 수
// 없고, 시작 자금 = $50 − (2~5행 순비용), 선 플레이어가 되면 입찰액도 뺀다.
// ---------------------------------------------------------------------------

/// 시트 한 줄의 선택지: (표시 값, 비용 — 음수는 돈을 받음).
typedef _Option = (String, int);

class _Line {
  const _Line(this.title, this.subtitle, this.icon, this.options);

  final String title;
  final String subtitle;
  final IconData icon;
  final List<_Option> options;
}

const _lines = <_Line>[
  _Line('상품 큐브', '시작 시 받을 상품 큐브 수', Icons.inventory_2_outlined, [
    ('2개', 6),
    ('3개', 9),
    ('4개', 12),
    ('5개', 15),
    ('6개', 18),
  ]),
  _Line('로비 직원', '활성 직원 5명에 더해 로비에 눕혀 둘 직원 수', Icons.person_outline, [
    ('3명', 0),
    ('4명', 8),
    ('5명', 16),
    ('6명', 24),
    ('7명', 32),
  ]),
  _Line('승점', '시작 승점 조정 — 승점을 낮추면 돈을 받습니다', Icons.star_outline, [
    ('-6점', -12),
    ('-3점', -6),
    ('0점', 0),
    ('+3점', 6),
    ('+6점', 12),
  ]),
  _Line('준비 이동', '게임 준비 마지막에 직원을 이동시킬 횟수', Icons.directions_walk, [
    ('4회', 5),
    ('5회', 8),
    ('6회', 10),
    ('8회', 15),
    ('10회', 20),
  ]),
];

/// 예산 한도.
const _budget = 50;

class NewBeginningScreen extends StatefulWidget {
  const NewBeginningScreen({super.key});

  @override
  State<NewBeginningScreen> createState() => _NewBeginningScreenState();
}

class _NewBeginningScreenState extends State<NewBeginningScreen> {
  /// 줄별 선택 인덱스 (기본값: 각 줄의 최저가 선택지).
  final _selected = <int>[0, 0, 2, 0];
  final _bidController = TextEditingController();

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  int get _bid => int.tryParse(_bidController.text) ?? 0;

  /// 2~5행 순비용 (승점 줄은 음수일 수 있음).
  int get _spent {
    var sum = 0;
    for (final (i, line) in _lines.indexed) {
      sum += line.options[_selected[i]].$2;
    }
    return sum;
  }

  bool get _overBudget => _spent + _bid > _budget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672),
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
                      Text('새로운 시작', style: CarbonText.heading05),
                      const SizedBox(height: CarbonSpacing.s3),
                      Text(
                        '시작 자원을 \$$_budget 한도 안에서 선택하세요. 모든 줄에서 '
                        '하나씩 고른 뒤, 각자 비밀리에 정해 동시에 공개합니다. '
                        '가장 많이 입찰한 사람이 선 플레이어가 됩니다.',
                        style: CarbonText.body01.copyWith(
                          color: CarbonColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: CarbonSpacing.s6),
                      _sectionHeader(
                        '선 플레이어 입찰',
                        '선 플레이어가 된 사람만 입찰액을 지불합니다',
                        Icons.gavel_outlined,
                      ),
                      const SizedBox(height: CarbonSpacing.s4),
                      _bidField(),
                      for (final (i, line) in _lines.indexed) ...[
                        const SizedBox(height: CarbonSpacing.s6),
                        _sectionHeader(line.title, line.subtitle, line.icon),
                        const SizedBox(height: CarbonSpacing.s4),
                        _optionRows(i, line),
                      ],
                      const SizedBox(height: CarbonSpacing.s6),
                      _summaryCard(),
                      const SizedBox(height: CarbonSpacing.s8),
                    ],
                  ),
                ),
                _bottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 선택지 5개를 두 줄(3개 + 2개)로 배치한다 (사용자 확정 레이아웃).
  /// 모든 칸은 3열 기준의 같은 폭 — 아랫줄 2개도 윗줄과 동일한 크기.
  Widget _optionRows(int lineIndex, _Line line) {
    Widget chip(int j, double width) => SizedBox(
      width: width,
      child: _OptionChip(
        label: line.options[j].$1,
        cost: line.options[j].$2,
        selected: _selected[lineIndex] == j,
        onTap: () => setState(() => _selected[lineIndex] = j),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 2 * CarbonSpacing.s3) / 3;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                chip(0, width),
                const SizedBox(width: CarbonSpacing.s3),
                chip(1, width),
                const SizedBox(width: CarbonSpacing.s3),
                chip(2, width),
              ],
            ),
            const SizedBox(height: CarbonSpacing.s3),
            Row(
              children: [
                chip(3, width),
                const SizedBox(width: CarbonSpacing.s3),
                chip(4, width),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _sectionHeader(String title, String subtitle, IconData icon) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: CarbonColors.textPrimary),
              const SizedBox(width: CarbonSpacing.s3),
              Expanded(child: Text(title, style: CarbonText.heading02)),
            ],
          ),
          if (subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(subtitle, style: CarbonText.helperText01),
            ),
        ],
      ),
    );
  }

  Widget _bidField() {
    return TextField(
      controller: _bidController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
      style: CarbonText.body02,
      decoration: const InputDecoration(
        filled: true,
        fillColor: CarbonColors.field01,
        prefixText: '\$ ',
        hintText: '0',
        hintStyle: TextStyle(color: CarbonColors.textHelper),
        contentPadding: EdgeInsets.symmetric(
          horizontal: CarbonSpacing.s5,
          vertical: CarbonSpacing.s4,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: CarbonColors.borderStrong),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: CarbonColors.borderStrong),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: CarbonColors.interactive, width: 2),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _summaryCard() {
    final goods = _lines[0].options[_selected[0]].$1;
    final workers = _lines[1].options[_selected[1]].$1;
    final vp = _lines[2].options[_selected[2]].$1;
    final moves = _lines[3].options[_selected[3]].$1;
    final rows = <(String, String)>[
      ('상품 큐브', goods),
      ('직원', '활성 5명 + 로비 $workers'),
      ('시작 승점', vp),
      ('준비 이동', moves),
      ('시작 자금 (선이 아닐 때)', '\$${_budget - _spent}'),
      ('시작 자금 (선일 때)', '\$${_budget - _spent - _bid}'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: CarbonColors.background,
        border: Border.all(color: CarbonColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CarbonSpacing.s5,
              vertical: CarbonSpacing.s3,
            ),
            color: CarbonColors.layer01,
            child: Text(
              '시작 상태 요약',
              style: CarbonText.heading01.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          for (final (i, row) in rows.indexed) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                indent: CarbonSpacing.s5,
                color: Color(0xFFE4E6E7),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CarbonSpacing.s5,
                vertical: CarbonSpacing.s4,
              ),
              child: Row(
                children: [
                  Expanded(child: Text(row.$1, style: CarbonText.body01)),
                  Text(
                    row.$2,
                    style: CarbonText.body01.copyWith(
                      fontWeight: FontWeight.w700,
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

  Widget _bottomBar() {
    final remain = _budget - _spent - _bid;
    return Container(
      decoration: const BoxDecoration(
        color: CarbonColors.background,
        border: Border(top: BorderSide(color: CarbonColors.borderSubtle)),
      ),
      padding: const EdgeInsets.all(CarbonSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_overBudget) ...[
            Container(
              color: CarbonColors.notifErrorBg,
              padding: const EdgeInsets.symmetric(
                horizontal: CarbonSpacing.s4,
                vertical: CarbonSpacing.s3,
              ),
              child: Text(
                '한도 초과 — 입찰을 포함한 총액이 \$$_budget를 넘을 수 없습니다',
                style: CarbonText.body01.copyWith(
                  color: CarbonColors.supportError,
                ),
              ),
            ),
            const SizedBox(height: CarbonSpacing.s3),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  '지출 \$$_spent · 입찰 \$$_bid',
                  style: CarbonText.body01.copyWith(
                    color: CarbonColors.textSecondary,
                  ),
                ),
              ),
              Text(
                '남는 예산 \$$remain',
                style: CarbonText.heading02.copyWith(
                  color: _overBudget
                      ? CarbonColors.supportError
                      : CarbonColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 시트 선택지 칩: 값 + 비용, 각진 모서리, 선택 시 인터랙티브 보더.
class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.cost,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int cost;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final costLabel = switch (cost) {
      0 => '무료',
      < 0 => '+\$${-cost}',
      _ => '\$$cost',
    };
    return Material(
      color: selected ? CarbonColors.interactiveTint : CarbonColors.background,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected
              ? CarbonColors.interactive
              : CarbonColors.borderSubtle,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        hoverColor: CarbonColors.interactiveTint,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: CarbonSpacing.s3),
          child: Column(
            children: [
              Text(
                label,
                style: CarbonText.body01.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                costLabel,
                style: CarbonText.helperText01.copyWith(
                  color: cost < 0
                      ? CarbonColors.supportSuccess
                      : CarbonColors.textHelper,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

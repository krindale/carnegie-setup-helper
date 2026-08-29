import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'carbon.dart';
import 'departments.dart';
import 'reference.dart';
import 'setup9.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const CarnegieApp());
}

/// 모든 스크롤에 바운스(iOS 스타일) 물리 적용.
class _BouncyScrollBehavior extends MaterialScrollBehavior {
  const _BouncyScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}

class CarnegieApp extends StatelessWidget {
  const CarnegieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carnegie 부서 타일 셀렉터',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _BouncyScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'SUIT',
        scaffoldBackgroundColor: CarbonColors.pageBackground,
        colorScheme: const ColorScheme.light(
          primary: CarbonColors.interactive,
          surface: CarbonColors.background,
        ),
        splashFactory: NoSplash.splashFactory,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
            TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const SetupScreen(),
    );
  }
}

/// 규칙서 15쪽 지역 배너 색상.
const regionColors = <String, Color>{
  '서부': Color(0xFFC2B49B),
  '중서부': Color(0xFFC0503C),
  '남부': Color(0xFF65A76B),
  '동부': Color(0xFF885F88),
};

/// Per-department exclusion state, in physical-setup terms.
enum TileState { removeBoth, removeOne, keepBoth }

extension on DrawResult {
  TileState stateOf(Department d) => switch (removedOf(d)) {
    2 => TileState.removeBoth,
    1 => TileState.removeOne,
    _ => TileState.keepBoth,
  };
}

// ---------------------------------------------------------------------------
// Setup screen
// ---------------------------------------------------------------------------

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int? _players;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 672),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(CarbonSpacing.s5),
                        children: [
                          const SizedBox(height: CarbonSpacing.s7),
                          Text('게임 준비', style: CarbonText.heading05),
                          const SizedBox(height: CarbonSpacing.s3),
                          Text(
                            '인원수만 선택하면 부서 타일 제외와 중립 디스크 배치가 '
                            '한 번에 준비됩니다.',
                            style: CarbonText.body02.copyWith(
                              color: CarbonColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: CarbonSpacing.s7),
                          Text('플레이어 수', style: CarbonText.label01),
                          const SizedBox(height: CarbonSpacing.s3),
                          Column(
                            children: [
                              for (final row in const [
                                [1, 2],
                                [3, 4],
                              ]) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (final p in row) ...[
                                      Expanded(
                                        child: _PlayerTile(
                                          players: p,
                                          selected: _players == p,
                                          onTap: () =>
                                              setState(() => _players = p),
                                        ),
                                      ),
                                      if (p != row.last)
                                        const SizedBox(width: CarbonSpacing.s3),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: CarbonSpacing.s3),
                              ],
                            ],
                          ),
                          const SizedBox(height: CarbonSpacing.s7),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        CarbonSpacing.s5,
                        0,
                        CarbonSpacing.s5,
                        CarbonSpacing.s5,
                      ),
                      child: CarbonButton(
                        label: '부서 타일 뽑기',
                        icon: Icons.shuffle,
                        onPressed: _players == null
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ResultScreen(result: draw(_players!)),
                                  ),
                                );
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                children: [
                  TopIconButton(
                    icon: Icons.menu_book_outlined,
                    tooltip: '부서 도감',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DeptCatalogScreen(),
                      ),
                    ),
                  ),
                  TopIconButton(
                    icon: Icons.info_outline,
                    tooltip: '아이콘 참조표',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const IconReferenceScreen(),
                      ),
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

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.players,
    required this.selected,
    required this.onTap,
  });

  final int players;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final removed = removalByPlayerCount[players]!;
    final kept = 32 - removed;
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
        hoverColor: CarbonColors.layerHover01,
        child: Padding(
          padding: const EdgeInsets.all(CarbonSpacing.s5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/pcount/p$players.png',
                    height: 18,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: CarbonSpacing.s3),
                  Expanded(
                    child: Text(
                      '$players인',
                      style: CarbonText.heading03.copyWith(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: selected
                        ? CarbonColors.interactive
                        : CarbonColors.borderStrong,
                  ),
                ],
              ),
              const SizedBox(height: CarbonSpacing.s5),
              Text(
                '타일 $removed개 제외',
                style: CarbonText.body01.copyWith(
                  color: CarbonColors.supportError,
                ),
              ),
              Text('$kept개 사용', style: CarbonText.helperText01),
              Text(
                disksByPlayerCount[players]! > 0
                    ? '중립 디스크 ${disksByPlayerCount[players]}개'
                    : '중립 디스크 없음',
                style: CarbonText.helperText01,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Result screen
// ---------------------------------------------------------------------------

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.result});

  final DrawResult result;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late DrawResult _result = widget.result;
  late DiskSetup _disks = drawDisks(widget.result.playerCount);
  int _tab = 0;
  bool _detail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1056),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CarbonSpacing.s5,
                  ),
                  child: TopBar(onBack: () => Navigator.of(context).pop()),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: CarbonSpacing.s5,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: CarbonColors.borderSubtle),
                    ),
                  ),
                  child: Row(
                    children: [
                      _TabButton(
                        label: '부서 타일',
                        icon: Icons.grid_view,
                        selected: _tab == 0,
                        onTap: () => setState(() => _tab = 0),
                      ),
                      _TabButton(
                        label: '중립 디스크',
                        icon: Icons.circle,
                        selected: _tab == 1,
                        onTap: () => setState(() => _tab = 1),
                      ),
                      if (_result.playerCount == 1)
                        _TabButton(
                          label: '1인 도우미',
                          icon: Icons.person_outline,
                          selected: _tab == 2,
                          onTap: () => setState(() => _tab = 2),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: switch (_tab) {
                    0 => _deptTab(),
                    1 => _diskTab(),
                    _ => _soloAidTab(),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _deptTab() {
    // 요약: 제외된 타일만 번호순 · 상세: 16종 전체 번호순(사용/제외 표시).
    final shown = _detail
        ? ([...departments]..sort((a, b) => a.number.compareTo(b.number)))
        : (departments
              .where((d) => _result.stateOf(d) != TileState.keepBoth)
              .toList()
            ..sort((a, b) => a.number.compareTo(b.number)));
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(CarbonSpacing.s5),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_result.playerCount}인 게임',
                      style: CarbonText.heading05,
                    ),
                  ),
                  CarbonContentSwitcher(
                    labels: const ['요약', '상세'],
                    selected: _detail ? 1 : 0,
                    onChanged: (i) => setState(() => _detail = i == 1),
                  ),
                ],
              ),
              const SizedBox(height: CarbonSpacing.s5),
              _SummaryBar(result: _result),
              const SizedBox(height: CarbonSpacing.s5),
              Row(
                children: [
                  CarbonButton(
                    label: '다시 뽑기',
                    icon: Icons.shuffle,
                    expanded: false,
                    onPressed: () =>
                        setState(() => _result = draw(_result.playerCount)),
                  ),
                  const SizedBox(width: CarbonSpacing.s3),
                  CarbonButton(
                    label: '인원 변경',
                    icon: Icons.arrow_back,
                    kind: CarbonButtonKind.tertiary,
                    expanded: false,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: CarbonSpacing.s4),
            ],
          ),
        ),
        if (!_detail)
          _deptGrid(shown)
        else
          for (final type in DeptType.values) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                CarbonSpacing.s5,
                CarbonSpacing.s4,
                CarbonSpacing.s5,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Container(
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
                      Text(type.ko, style: CarbonText.heading02),
                      const SizedBox(width: CarbonSpacing.s3),
                      Text(type.en, style: CarbonText.helperText01),
                    ],
                  ),
                ),
              ),
            ),
            _deptGrid(shown.where((d) => d.type == type).toList()),
          ],
        const SliverToBoxAdapter(child: SizedBox(height: CarbonSpacing.s8)),
      ],
    );
  }

  Widget _deptGrid(List<Department> depts) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        CarbonSpacing.s5,
        CarbonSpacing.s4,
        CarbonSpacing.s5,
        0,
      ),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          // 카드 = 타이틀 행 + 타일 이미지(497:426), 내용 높이에 맞춤.
          final width = constraints.crossAxisExtent;
          final cols = (width / 240).ceil().clamp(1, 6);
          final colWidth = (width - (cols - 1) * CarbonSpacing.s4) / cols;
          final imageHeight = (colWidth - 2 * CarbonSpacing.s3) / (497 / 426);
          final extent =
              CarbonSpacing.s3 +
              24 +
              CarbonSpacing.s2 +
              imageHeight +
              CarbonSpacing.s3;
          return SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisExtent: extent,
              crossAxisSpacing: CarbonSpacing.s4,
              mainAxisSpacing: CarbonSpacing.s4,
            ),
            itemCount: depts.length,
            itemBuilder: (context, i) => _DeptCard(
              dept: depts[i],
              state: _result.stateOf(depts[i]),
              onTap: () => _showDetail(depts[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _diskTab() {
    if (_result.playerCount == 1) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(CarbonSpacing.s7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.block,
                size: 64,
                color: CarbonColors.borderStrong,
              ),
              const SizedBox(height: CarbonSpacing.s6),
              Text('중립 디스크 없음', style: CarbonText.heading03),
              const SizedBox(height: CarbonSpacing.s3),
              Text(
                '1인 게임에서는 게임판에 미리 놓는 디스크가 없습니다',
                textAlign: TextAlign.center,
                style: CarbonText.body01.copyWith(
                  color: CarbonColors.textHelper,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_disks.totalDisks == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(CarbonSpacing.s7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.block,
                size: 64,
                color: CarbonColors.borderStrong,
              ),
              const SizedBox(height: CarbonSpacing.s6),
              Text('중립 디스크를 사용하지 않습니다', style: CarbonText.heading03),
              const SizedBox(height: CarbonSpacing.s3),
              Text(
                '4인 게임에서는 이 과정을 생략합니다',
                textAlign: TextAlign.center,
                style: CarbonText.body01.copyWith(
                  color: CarbonColors.textHelper,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(CarbonSpacing.s5),
      children: [
        Text('중립 디스크 ${_disks.totalDisks}개', style: CarbonText.heading05),
        const SizedBox(height: CarbonSpacing.s3),
        Text(
          '게임에 참여하지 않는 색상의 디스크를 아래대로 게임판에 놓으세요.',
          style: CarbonText.body01.copyWith(color: CarbonColors.textSecondary),
        ),
        const SizedBox(height: CarbonSpacing.s5),
        CarbonButton(
          label: '다시 뽑기',
          icon: Icons.shuffle,
          expanded: false,
          onPressed: () =>
              setState(() => _disks = drawDisks(_result.playerCount)),
        ),
        const SizedBox(height: CarbonSpacing.s6),
        _diskSectionHeader(
          '기부 차트',
          '${_disks.donations.length}개 · 표시된 칸에 디스크 1개씩',
          Icons.volunteer_activism_outlined,
        ),
        const SizedBox(height: CarbonSpacing.s4),
        _DiskListCard(
          rows: [
            for (final code in ([..._disks.donations]..sort()))
              (code, '${donationRows[code[0]]} · ${code.substring(1)}번 칸', 1),
          ],
          showCount: false,
        ),
        const SizedBox(height: CarbonSpacing.s6),
        _diskSectionHeader(
          '도시 건설 부지',
          '${_disks.cityTotal}개 · 각 도시의 가장 왼쪽 빈 건설 부지부터',
          Icons.location_city,
        ),
        for (final region in cityRegions.keys)
          if (cityRegions[region]!.any(_disks.cityDisks.containsKey)) ...[
            const SizedBox(height: CarbonSpacing.s4),
            _DiskListCard(
              title: region,
              titleColor: regionColors[region],
              rows: [
                for (final city in cityRegions[region]!)
                  if (_disks.cityDisks.containsKey(city))
                    (null, city, _disks.cityDisks[city]!),
              ],
              showCount: true,
            ),
          ],
        const SizedBox(height: CarbonSpacing.s8),
      ],
    );
  }

  Widget _soloAidTab() {
    return ListView(
      padding: const EdgeInsets.all(CarbonSpacing.s5),
      children: [
        Text('1인 도우미', style: CarbonText.heading05),
        const SizedBox(height: CarbonSpacing.s3),
        Text(
          '앤드류 카네기를 상대하는 라운드 진행 요약입니다.',
          style: CarbonText.body01.copyWith(color: CarbonColors.textSecondary),
        ),
        const SizedBox(height: CarbonSpacing.s6),
        _diskSectionHeader('라운드 진행', '5단계', Icons.loop),
        const SizedBox(height: CarbonSpacing.s4),
        const _DiskListCard(
          showCount: false,
          rows: [
            ('1', '새 행동 카드 — 앤드류의 맨 위 카드를 보지 않고 0점 카드 아래 뒷면으로 놓기', 0),
            ('2', '행동 선택 — 기관차 왼쪽: 플레이어가 선택 · 오른쪽: 카드를 공개해 앤드류가 선택', 0),
            ('3', '앤드류의 차례 — 이벤트 처리 후 카드의 행동 해결', 0),
            ('4', '플레이어의 차례 — 이벤트(수입/기부) 해결 후 해당 종류 부서 사용', 0),
            (
              '5',
              '라운드 종료 — 직원 활성화 → 행동 마커 1칸 전진 → 카드를 도달한 승점 카드 아래 뒷면으로 → 기관차를 반대편으로',
              0,
            ),
          ],
        ),
        const SizedBox(height: CarbonSpacing.s6),
        _diskSectionHeader(
          '앤드류 행동 해결',
          '불가 1건당 카드 1칸 오른쪽 이동',
          Icons.smart_toy_outlined,
        ),
        const SizedBox(height: CarbonSpacing.s4),
        const _DiskListCard(
          showCount: false,
          rows: [
            (null, '인사 — 카드에 표시된 칸 수만큼 카드를 오른쪽으로 이동', 0),
            (null, '경영 — 표시된 종류의 부서 타일 1~3개 획득 (항상 가장 낮은 번호부터)', 0),
            (null, '건설 — 표시된 각 도시의 가장 왼쪽 건설 부지에 디스크 1개씩', 0),
            (null, 'R&D — 표시된 지역의 운송 디스크를 1~3칸 오른쪽으로 이동', 0),
          ],
        ),
        const SizedBox(height: CarbonSpacing.s6),
        _diskSectionHeader('이벤트 (앤드류)', '', Icons.event_note_outlined),
        const SizedBox(height: CarbonSpacing.s4),
        const _DiskListCard(
          showCount: false,
          rows: [
            (null, '파견 칸 — 앤드류에게는 아무 일도 일어나지 않음', 0),
            (
              null,
              '기부 칸 — 카드 상단의 기부 칸에 디스크 1개 (칸이 차 있으면 생략) 후 카드를 오른쪽으로 1칸',
              0,
            ),
          ],
        ),
        const SizedBox(height: CarbonSpacing.s6),
        _diskSectionHeader('앤드류 점수 계산', '게임 종료 시', Icons.emoji_events_outlined),
        const SizedBox(height: CarbonSpacing.s4),
        const _DiskListCard(
          showCount: false,
          rows: [
            (null, '행동 카드 — 놓인 승점 카드의 점수만큼', 0),
            (null, '부서 타일 1개당 2점', 0),
            (null, '운송 트랙 마지막 칸 도달 디스크 1개당 6점', 0),
            (null, '건설 디스크 — 도시에 표시된 0~3점', 0),
            (null, '기부 디스크 — 플레이어의 진행 기준으로 계산', 0),
          ],
        ),
        const SizedBox(height: CarbonSpacing.s8),
      ],
    );
  }

  Widget _diskSectionHeader(String title, String subtitle, IconData icon) {
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
      child: Row(
        children: [
          Icon(icon, size: 18, color: CarbonColors.textPrimary),
          const SizedBox(width: CarbonSpacing.s3),
          Text(title, style: CarbonText.heading02),
          const SizedBox(width: CarbonSpacing.s3),
          Expanded(
            child: Text(
              subtitle,
              style: CarbonText.helperText01,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(Department d) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CarbonColors.background,
      shape: const RoundedRectangleBorder(),
      constraints: const BoxConstraints(maxWidth: 672),
      isScrollControlled: true,
      builder: (context) =>
          _DeptDetailSheet(dept: d, removedCount: _result.removedOf(d)),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.result});

  final DrawResult result;

  @override
  Widget build(BuildContext context) {
    Widget stat(String label, int value, Color color, IconData icon) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(CarbonSpacing.s5),
          decoration: BoxDecoration(
            color: CarbonColors.layer01,
            border: Border(top: BorderSide(color: color, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: CarbonColors.textSecondary),
                  const SizedBox(width: CarbonSpacing.s2),
                  Expanded(child: Text(label, style: CarbonText.label01)),
                ],
              ),
              const SizedBox(height: CarbonSpacing.s2),
              Text(
                '$value',
                style: CarbonText.heading04.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        stat(
          '상자에 되돌릴 타일',
          result.totalRemoved,
          CarbonColors.supportError,
          Icons.archive_outlined,
        ),
        const SizedBox(width: CarbonSpacing.s3),
        stat(
          '테이블에 놓을 타일',
          result.totalKept,
          CarbonColors.supportSuccess,
          Icons.table_bar_outlined,
        ),
      ],
    );
  }
}

class _DeptCard extends StatelessWidget {
  const _DeptCard({
    required this.dept,
    required this.state,
    required this.onTap,
  });

  final Department dept;
  final TileState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (tagIcon, tagCount, tagBg, tagFg) = switch (state) {
      TileState.removeBoth => (
        Icons.close,
        '2',
        const Color(0x99DA1E28),
        CarbonColors.textOnColor,
      ),
      TileState.removeOne => (
        Icons.close,
        '1',
        const Color(0x99F1C21B),
        CarbonColors.textOnColor,
      ),
      TileState.keepBoth => (
        Icons.check,
        null,
        const Color(0x9924A148),
        CarbonColors.textOnColor,
      ),
    };

    return Material(
      color: CarbonColors.background,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: CarbonColors.borderSubtle),
      ),
      child: InkWell(
        onTap: onTap,
        hoverColor: CarbonColors.layer01,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CarbonSpacing.s3,
                CarbonSpacing.s3,
                CarbonSpacing.s3,
                0,
              ),
              child: Text(
                '${dept.number}. ${dept.ko}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CarbonText.heading02,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  CarbonSpacing.s3,
                  CarbonSpacing.s2,
                  CarbonSpacing.s3,
                  CarbonSpacing.s3,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        dept.image,
                        cacheWidth: 512,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      bottom: CarbonSpacing.s3,
                      right: CarbonSpacing.s3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(tagIcon, size: 14, color: tagFg),
                            if (tagCount != null) ...[
                              const SizedBox(width: 2),
                              Text(
                                tagCount,
                                style: CarbonText.label01.copyWith(
                                  color: tagFg,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeTag extends StatelessWidget {
  const _TypeTag({required this.type});

  final DeptType type;

  @override
  Widget build(BuildContext context) {
    return CarbonTag(
      text: type.ko,
      bg: CarbonColors.tagGrayBg,
      fg: CarbonColors.tagGrayText,
    );
  }
}

class _DeptDetailSheet extends StatelessWidget {
  const _DeptDetailSheet({required this.dept, required this.removedCount});

  final Department dept;
  final int removedCount;

  @override
  Widget build(BuildContext context) {
    final kept = copiesPerDepartment - removedCount;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CarbonSpacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dept.number}. ${dept.ko}',
                        style: CarbonText.heading03,
                      ),
                      const SizedBox(height: 2),
                      Text(dept.en, style: CarbonText.helperText01),
                    ],
                  ),
                ),
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
            Center(
              child: Image.asset(
                dept.image,
                width: 260,
                cacheWidth: 600,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: CarbonSpacing.s5),
            Wrap(
              spacing: CarbonSpacing.s2,
              runSpacing: CarbonSpacing.s2,
              children: [
                _TypeTag(type: dept.type),
                if (dept.ongoing)
                  const CarbonTag(
                    text: '지속 효과',
                    bg: CarbonColors.tagAccentBg,
                    fg: CarbonColors.tagAccentText,
                  ),
                if (removedCount > 0)
                  CarbonTag(
                    text: '$removedCount장 제외',
                    bg: CarbonColors.tagRedBg,
                    fg: CarbonColors.tagRedText,
                  ),
                if (kept > 0)
                  CarbonTag(
                    text: '$kept장 사용',
                    bg: CarbonColors.tagGreenBg,
                    fg: CarbonColors.tagGreenText,
                  ),
              ],
            ),
            const SizedBox(height: CarbonSpacing.s5),
            Text('규칙', style: CarbonText.label01),
            const SizedBox(height: CarbonSpacing.s2),
            Text(dept.rule, style: CarbonText.body02),
          ],
        ),
      ),
    );
  }
}

/// Carbon line tab.
class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: CarbonColors.layerHover01,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: CarbonSpacing.s5,
          vertical: CarbonSpacing.s4,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? CarbonColors.interactive : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected
                    ? CarbonColors.textPrimary
                    : CarbonColors.textHelper,
              ),
              const SizedBox(width: CarbonSpacing.s2),
            ],
            Text(
              label,
              style: CarbonText.body01.copyWith(
                color: selected
                    ? CarbonColors.textPrimary
                    : CarbonColors.textHelper,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White card listing disk placements: optional leading code badge,
/// label, optional trailing count tag.
class _DiskListCard extends StatelessWidget {
  const _DiskListCard({
    required this.rows,
    required this.showCount,
    this.title,
    this.titleColor,
  });

  /// (badge code or null, label, count)
  final List<(String?, String, int)> rows;
  final bool showCount;

  /// Optional header row (e.g., map region name).
  final String? title;

  /// Header banner color (rulebook region color).
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CarbonColors.background,
        border: Border.all(color: CarbonColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: CarbonSpacing.s5,
                vertical: CarbonSpacing.s3,
              ),
              color: titleColor ?? CarbonColors.layer01,
              child: Text(
                title!,
                style: CarbonText.heading01.copyWith(
                  color: titleColor != null
                      ? CarbonColors.textOnColor
                      : CarbonColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
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
                  if (row.$1 != null) ...[
                    Container(
                      width: 40,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: CarbonColors.interactiveTint,
                        border: Border.all(color: CarbonColors.interactive),
                      ),
                      child: Text(
                        row.$1!,
                        style: CarbonText.label01.copyWith(
                          color: CarbonColors.interactive,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: CarbonSpacing.s4),
                  ],
                  Expanded(child: Text(row.$2, style: CarbonText.body01)),
                  if (showCount)
                    CarbonTag(
                      text: '${row.$3}개',
                      bg: CarbonColors.tagGrayBg,
                      fg: CarbonColors.tagGrayText,
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'carbon.dart';
import 'departments.dart';
import 'dept_tile.dart';
import 'new_beginning.dart';
import 'reference.dart';
import 'rules.dart';
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

/// 1인 게임 준비는 2인과 동일하므로 하나의 선택지로 합친다.
String playerLabel(int p) => p == 2 ? '1-2인' : '$p인';

/// Per-department exclusion state, in physical-setup terms.
/// [boxedKind]: 확장 모드에서 유형별 4종 선택에 들지 못해 통째로 상자에
/// 되돌아가는 종류.
enum TileState { removeBoth, removeOne, keepBoth, boxedKind }

extension on DrawResult {
  TileState stateOf(Department d) {
    if (isExpansion && !selectedKinds!.contains(d.number)) {
      return TileState.boxedKind;
    }
    return switch (removedOf(d)) {
      2 => TileState.removeBoth,
      1 => TileState.removeOne,
      _ => TileState.keepBoth,
    };
  }
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
  /// 확장 #1 "새로운 부서" 포함 여부 (세션 한정, 기본 꺼짐).
  bool _expansion = false;

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
                      // 인원 카드 3장이 남는 세로 공간을 균등하게 나눠 화면을
                      // 채운다. 공간이 부족하면 스크롤 목록으로 전환된다.
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final header = <Widget>[
                            const SizedBox(height: CarbonSpacing.s7),
                            Text('게임 준비', style: CarbonText.heading05),
                            const SizedBox(height: CarbonSpacing.s4),
                            Text(
                              '부서 타일 제외 · 중립 디스크 배치 한 번에',
                              style: CarbonText.body02.copyWith(
                                color: CarbonColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: CarbonSpacing.s5),
                            // 기본판/확장 스위치는 서브 타이틀 아래에 둔다
                            // (사용자 확정).
                            Row(
                              children: [
                                CarbonContentSwitcher(
                                  labels: const ['기본판', '확장 포함'],
                                  selected: _expansion ? 1 : 0,
                                  onChanged: (i) =>
                                      setState(() => _expansion = i == 1),
                                ),
                              ],
                            ),
                            // 모드 설명은 스위치와 인원 카드 사이 중간에,
                            // 고정 높이로 자리를 잡아 두고 문구만 바꿔서
                            // 전환 시 아래 레이아웃이 흔들리지 않게 한다.
                            const SizedBox(height: CarbonSpacing.s4),
                            SizedBox(
                              height: 16,
                              child: Text(
                                _expansion
                                    ? '유형별 8종 중 4종을 추려 16종으로 플레이합니다'
                                    : '기본판 부서 16종을 그대로 사용합니다',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: CarbonText.helperText01,
                              ),
                            ),
                            const SizedBox(height: CarbonSpacing.s4),
                          ];
                          Widget tile(int p) => _PlayerTile(
                            players: p,
                            expansion: _expansion,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ResultScreen(
                                  result: _expansion
                                      ? drawExpansion(p)
                                      : draw(p),
                                ),
                              ),
                            ),
                          );
                          if (constraints.maxHeight < 620) {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(CarbonSpacing.s5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...header,
                                  for (final p in const [2, 3, 4]) ...[
                                    tile(p),
                                    if (p != 4)
                                      const SizedBox(height: CarbonSpacing.s3),
                                  ],
                                ],
                              ),
                            );
                          }
                          // 카드:간격 = 170:15 — 간격을 이전(85:15)의 절반
                          // 비율로 줄이고, 남는 공간은 카드가 가져간다.
                          return Padding(
                            padding: const EdgeInsets.all(CarbonSpacing.s5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...header,
                                for (final p in const [2, 3, 4]) ...[
                                  Expanded(flex: 170, child: tile(p)),
                                  const Spacer(flex: 15),
                                ],
                              ],
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
                    icon: Icons.article_outlined,
                    tooltip: '게임 룰 요약',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RulesSummaryScreen(),
                      ),
                    ),
                  ),
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
                  TopIconButton(
                    icon: Icons.calculate_outlined,
                    tooltip: '새로운 시작 계산기',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NewBeginningScreen(),
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
    required this.onTap,
    this.expansion = false,
  });

  final int players;

  /// 카드를 누르면 바로 뽑기 결과 화면으로 이동한다 (별도 확정 버튼 없음).
  final VoidCallback onTap;

  /// 확장 모드일 때 인원수 옆에 확장 표식 아이콘을 보여준다.
  final bool expansion;

  @override
  Widget build(BuildContext context) {
    final removed = removalByPlayerCount[players]!;
    // 기본판·확장 모두 16종×2장 = 32장으로 시작한다.
    final kept = departments.length * copiesPerDepartment - removed;
    return Material(
      color: CarbonColors.background,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: CarbonColors.borderSubtle),
      ),
      child: InkWell(
        onTap: onTap,
        hoverColor: CarbonColors.layerHover01,
        child: Padding(
          padding: const EdgeInsets.all(CarbonSpacing.s5),
          child: Column(
            // 카드가 세로로 늘어났을 때 내용을 세로 중앙에 둔다.
            mainAxisAlignment: MainAxisAlignment.center,
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
                    child: Row(
                      children: [
                        Text(
                          playerLabel(players),
                          style: CarbonText.heading03.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (expansion) ...[
                          const SizedBox(width: CarbonSpacing.s2),
                          const Icon(
                            Icons.dashboard_customize_outlined,
                            size: 14,
                            color: CarbonColors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: CarbonColors.interactive,
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

  /// 확장 요약의 슬라이딩 탭(종류 고르기 / 타일 제외) 상태.
  final PageController _expPage = PageController();
  int _expTab = 0;

  @override
  void dispose() {
    _expPage.dispose();
    super.dispose();
  }

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
                      if (_result.playerCount == 2)
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

  /// 결과 화면 공통 헤더: 제목 줄 + 요약 바 + 액션 버튼.
  List<Widget> _deptHeaderChildren() {
    return [
      Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  '${playerLabel(_result.playerCount)} 게임',
                  style: CarbonText.heading05,
                ),
                // 인원 카드와 같은 비율(글자 크기 대비)의 확장 표식.
                if (_result.isExpansion) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.dashboard_customize_outlined,
                    size: 22,
                    color: CarbonColors.textSecondary,
                  ),
                ],
              ],
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
            onPressed: () => setState(
              () => _result = _result.isExpansion
                  ? drawExpansion(_result.playerCount)
                  : draw(_result.playerCount),
            ),
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
    ];
  }

  /// 확장 요약: 종류 고르기 / 타일 제외를 슬라이딩 탭으로 (사용자 확정).
  Widget _expansionSummaryTab(List<Department> shown) {
    void goTo(int i) => _expPage.animateToPage(
      i,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            CarbonSpacing.s5,
            CarbonSpacing.s5,
            CarbonSpacing.s5,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _deptHeaderChildren(),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: CarbonSpacing.s5),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: CarbonColors.borderSubtle),
            ),
          ),
          child: Row(
            children: [
              _TabButton(
                label: '종류 고르기',
                icon: Icons.grid_view,
                selected: _expTab == 0,
                onTap: () => goTo(0),
              ),
              _TabButton(
                label: '타일 제외',
                icon: Icons.archive_outlined,
                selected: _expTab == 1,
                onTap: () => goTo(1),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView(
            controller: _expPage,
            onPageChanged: (i) => setState(() => _expTab = i),
            children: [
              ListView(
                padding: const EdgeInsets.all(CarbonSpacing.s5),
                children: [
                  Text(
                    '아래 번호만 2장씩 꺼내기 — 나머지는 상자로',
                    style: CarbonText.helperText01,
                  ),
                  const SizedBox(height: CarbonSpacing.s4),
                  _KindCleanupCard(result: _result, onTapDept: _showDetail),
                  const SizedBox(height: CarbonSpacing.s8),
                ],
              ),
              CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      CarbonSpacing.s5,
                      CarbonSpacing.s5,
                      CarbonSpacing.s5,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        '꺼내 온 32장에서 아래 타일을 표시된 장수만큼 빼세요',
                        style: CarbonText.helperText01,
                      ),
                    ),
                  ),
                  _deptGrid(shown),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: CarbonSpacing.s8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _deptTab() {
    // 요약(기본판): 제외 타일만 번호순 · 요약(확장): 슬라이딩 탭 2단계 —
    // 종류 고르기(번호 칩) → 타일 제외(그리드) (사용자 확정 B안).
    // 상세: 전체 종류 번호순(사용/제외 표시).
    final all = _result.isExpansion ? allDepartments : departments;
    final shown = _detail
        ? ([...all]..sort((a, b) => a.number.compareTo(b.number)))
        : (all
              .where(
                (d) =>
                    _result.stateOf(d) == TileState.removeBoth ||
                    _result.stateOf(d) == TileState.removeOne,
              )
              .toList()
            // 유형 순서(인사→경영→건설→연구개발), 같은 유형 안에서는 번호순.
            ..sort((a, b) {
              final byType = a.type.index.compareTo(b.type.index);
              return byType != 0 ? byType : a.number.compareTo(b.number);
            }));
    if (!_detail && _result.isExpansion) return _expansionSummaryTab(shown);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(CarbonSpacing.s5),
          sliver: SliverList.list(children: _deptHeaderChildren()),
        ),
        if (!_detail)
          _deptGrid(shown)
        else ...[
          if (_result.isExpansion)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: CarbonSpacing.s5),
              sliver: SliverList.list(
                children: [
                  _diskSectionHeader(
                    '종류 고르기',
                    '아래 번호만 2장씩 꺼내기 — 나머지는 상자로',
                    Icons.grid_view,
                  ),
                  const SizedBox(height: CarbonSpacing.s4),
                  _KindCleanupCard(result: _result, onTapDept: _showDetail),
                ],
              ),
            ),
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
                  decoration: BoxDecoration(
                    color: CarbonColors.layer01,
                    border: Border(
                      // 타일 넘버 플레이트와 같은 유형 컬러.
                      left: BorderSide(color: deptTypeColorOf(type), width: 4),
                    ),
                  ),
                  child: Row(
                    children: [
                      // 도감과 같은 공식 유형 아이콘 (참조표 i01~i04).
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
              ),
            ),
            _deptGrid(shown.where((d) => d.type == type).toList()),
          ],
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
          // 셀 = 타일 자체. 타일이 곧 카드다.
          final width = constraints.crossAxisExtent;
          final cols = (width / 240).ceil().clamp(1, 6);
          final colWidth = (width - (cols - 1) * CarbonSpacing.s4) / cols;
          final extent = colWidth / deptTileAspect;
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

  void _showDetail(Department d) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CarbonColors.background,
      shape: const RoundedRectangleBorder(),
      constraints: const BoxConstraints(maxWidth: 672),
      isScrollControlled: true,
      builder: (context) => _DeptDetailSheet(
        dept: d,
        removedCount: _result.removedOf(d),
        boxed: _result.stateOf(d) == TileState.boxedKind,
      ),
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

    // 확장(B안): 요약 2단계와 같은 순서 — ① 사용할 종류 ② 제외할 타일.
    if (result.isExpansion) {
      return Row(
        children: [
          stat(
            '사용할 종류',
            result.selectedKinds!.length,
            CarbonColors.supportSuccess,
            Icons.grid_view,
          ),
          const SizedBox(width: CarbonSpacing.s3),
          stat(
            '제외할 타일',
            result.totalRemoved,
            CarbonColors.supportError,
            Icons.archive_outlined,
          ),
        ],
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

/// 확장 요약 1단계: 유형별로 이번 게임에 사용할 종류를 번호 칩으로 나열.
class _KindCleanupCard extends StatelessWidget {
  const _KindCleanupCard({required this.result, required this.onTapDept});

  final DrawResult result;
  final void Function(Department) onTapDept;

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
          for (final (i, type) in DeptType.values.indexed) ...[
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
                  SizedBox(
                    width: 64,
                    child: Text(
                      type.ko,
                      style: CarbonText.heading01.copyWith(
                        color: deptTypeColorOf(type),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: CarbonSpacing.s3,
                      runSpacing: CarbonSpacing.s3,
                      children: [
                        for (final d in allDepartments.where(
                          (d) =>
                              d.type == type &&
                              result.selectedKinds!.contains(d.number),
                        ))
                          InkWell(
                            onTap: () => onTapDept(d),
                            child: DeptNumberPlate(dept: d, size: 32),
                          ),
                      ],
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
        Icons.delete,
        '×2',
        const Color(0x99DA1E28),
        CarbonColors.textOnColor,
      ),
      TileState.removeOne => (
        Icons.delete,
        '×1',
        const Color(0x99F1C21B),
        CarbonColors.textOnColor,
      ),
      TileState.keepBoth => (
        Icons.check,
        null,
        const Color(0x9924A148),
        CarbonColors.textOnColor,
      ),
      // 확장 모드: 유형별 선택에 들지 못해 통째로 상자로 가는 종류.
      TileState.boxedKind => (
        Icons.inventory_2_outlined,
        null,
        const Color(0x99A2999E),
        CarbonColors.textOnColor,
      ),
    };

    // 타일 자체가 그리드 셀이다. 상태 배지만 엠블럼 영역 우하단에 오버레이.
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          Positioned.fill(child: DeptTile(dept: dept)),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap, hoverColor: const Color(0x14353B3C)),
            ),
          ),
          // 효과 바 높이(기준 72px × 그리드 확대 1.3)에 비례해 그 위에 놓는다.
          Positioned(
            bottom: constraints.maxWidth * 72 * 1.3 / 400 + CarbonSpacing.s3,
            right: CarbonSpacing.s3,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
          ),
        ],
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
  const _DeptDetailSheet({
    required this.dept,
    required this.removedCount,
    this.boxed = false,
  });

  final Department dept;
  final int removedCount;

  /// 확장 모드에서 유형별 선택에 들지 못해 이번 게임에 쓰이지 않는 종류.
  final bool boxed;

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
                DeptNumberPlate(dept: dept),
                const SizedBox(width: CarbonSpacing.s4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dept.ko, style: CarbonText.heading03),
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
            DeptDoubleRule(dept: dept),
            const SizedBox(height: CarbonSpacing.s6),
            Center(child: DeptEmblem(dept: dept)),
            const SizedBox(height: CarbonSpacing.s6),
            DeptEffectBar(dept: dept),
            const SizedBox(height: CarbonSpacing.s5),
            Wrap(
              spacing: CarbonSpacing.s2,
              runSpacing: CarbonSpacing.s2,
              children: [
                _TypeTag(type: dept.type),
                if (dept.expansion)
                  const CarbonTag(
                    text: '확장',
                    bg: CarbonColors.tagGrayBg,
                    fg: CarbonColors.tagGrayText,
                  ),
                if (dept.ongoing)
                  const CarbonTag(
                    text: '지속 효과',
                    bg: CarbonColors.tagAccentBg,
                    fg: CarbonColors.tagAccentText,
                  ),
                if (dept.endgame)
                  const CarbonTag(
                    text: '게임 종료',
                    bg: CarbonColors.tagAccentBg,
                    fg: CarbonColors.tagAccentText,
                  ),
                if (boxed)
                  const CarbonTag(
                    text: '이번 게임 미사용',
                    bg: CarbonColors.tagGrayBg,
                    fg: CarbonColors.tagGrayText,
                  )
                else ...[
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

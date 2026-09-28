import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'carbon.dart';
import 'departments.dart';
import 'dept_tile.dart';
import 'l10n.dart';
import 'new_beginning.dart';
import 'reference.dart';
import 'rules.dart';
import 'setup9.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // 저장된 한영 선택 → 없으면 기기(브라우저) 언어로 시작 언어를 정한다.
  await loadAppLang();
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
    return ValueListenableBuilder(
      valueListenable: appLang,
      builder: (context, _, _) => _app(),
    );
  }

  Widget _app() {
    return MaterialApp(
      title: tr('Carnegie 부서 타일 셀렉터', 'Carnegie Department Tile Selector'),
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
String playerLabel(int p) =>
    p == 2 ? tr('1-2인', '1-2 Players') : tr('$p인', '$p Players');

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

/// 첫 화면 오버라인 줄(한영 스위치 포함)의 화면 위 끝 기준 위치.
/// 상단 아이콘 글리프 하단(위 8 + 버튼 여백 11 + 글리프 22 ≈ 39)에서
/// 15px 아래 (사용자 확정: 아이콘과 스위치 간격 15).
const _homeHeaderTop = 54.0;

/// 한영 스위치 높이 (dense 24 + 5, 사용자 확정). 오버라인 줄 높이도 같다.
const _langSwitchHeight = 29.0;

/// 한영 스위치 칸 폭과 전체 폭(두 칸 + 테두리 1px×2) — 기존 69px과
/// 1.5배 104px의 중간 86px (사용자 확정).
const _langSegmentWidth = 42.0;
const _langSwitchWidth = _langSegmentWidth * 2 + 2;

/// 본문 오른쪽 끝에서 스위치 오른쪽 끝까지 — 아이콘 참조표 아이콘 글리프
/// 끝선(44px 버튼 안 22px 글리프 → 버튼 끝에서 13px)에 맞춘다.
const _langSwitchInset = 13.0;

class _SetupScreenState extends State<SetupScreen> {
  /// 확장 #1 "새로운 부서" 포함 여부 (세션 한정, 기본 꺼짐).
  bool _expansion = false;

  // 기기 로캘이 늦게 전달되는 경우 등 스위치 밖에서 언어가 바뀌어도
  // 첫 화면을 다시 그린다.
  void _onLang() => setState(() {});

  @override
  void initState() {
    super.initState();
    appLang.addListener(_onLang);
  }

  @override
  void dispose() {
    appLang.removeListener(_onLang);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      // 인원 카드 3장이 남는 세로 공간을 균등하게 나눠 화면을
                      // 채운다. 공간이 부족하면 스크롤 목록으로 전환된다.
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final header = <Widget>[
                            // 본문 패딩(16)을 빼고 _homeHeaderTop에서 오버라인 시작.
                            const SizedBox(
                              height: _homeHeaderTop - CarbonSpacing.s5,
                            ),
                            // 앱 정체(카네기 셋업 도우미)를 첫 화면에서 드러내는
                            // 오버라인 (시안 A, docs/mockups/home-title.html).
                            // 오버라인 줄 높이는 한영 스위치(_langSwitchHeight)에 맞춘다.
                            // 스위치 자체는 아이콘과 끝선을 맞추려고 아래
                            // Stack에서 화면 기준으로 배치한다.
                            // 오른쪽은 스위치 자리(+ 간격 8)를 비워 두고, 좁은
                            // 폭에서 글자가 스위치에 닿을 때만 축소한다.
                            SizedBox(
                              height: _langSwitchHeight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right:
                                      _langSwitchInset + _langSwitchWidth + 8,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      tr(
                                        'CARNEGIE · 카네기 셋업 도우미',
                                        'CARNEGIE · SETUP HELPER',
                                      ),
                                      maxLines: 1,
                                      style: CarbonText.helperText01,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: CarbonSpacing.s3),
                            Text(
                              tr('게임 준비', 'Game Setup'),
                              style: CarbonText.heading05,
                            ),
                            const SizedBox(height: CarbonSpacing.s4),
                            // 한 줄 고정: 좁은 폭에서 줄바꿈되면 헤더가 길어져
                            // 인원 카드가 넘치므로, 넘칠 때만 폭에 맞게 축소한다.
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                tr(
                                  '부서 타일 제외 · 중립 디스크 배치 한 번에',
                                  'Remove Department tiles · place neutral disks',
                                ),
                                maxLines: 1,
                                style: CarbonText.body02.copyWith(
                                  color: CarbonColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: CarbonSpacing.s5),
                            // 기본판/확장 스위치는 서브 타이틀 아래에 둔다
                            // (사용자 확정).
                            Row(
                              children: [
                                CarbonContentSwitcher(
                                  labels: [
                                    tr('기본판', 'Base Game'),
                                    tr('확장 포함', 'With Expansion'),
                                  ],
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
                                    ? tr(
                                        '유형별 8종 중 4종을 추려 16종으로 플레이합니다',
                                        'Draw 4 of the 8 Departments of each type — 16 in play',
                                      )
                                    : tr(
                                        '기본판 부서 16종을 그대로 사용합니다',
                                        'Uses the 16 base-game Departments as they are',
                                      ),
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
                          // 700 미만이면 카드 최소 높이(약 128px)가 안 나와
                          // 넘치므로 스크롤 목록으로 전환한다.
                          if (constraints.maxHeight < 700) {
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
                // 상단 아이콘: 세부 페이지와 같은 TopBar(본문 열 안, 좌우 16 ·
                // 위 8)를 본문 위에 겹쳐 둔다 — 본문 위치는 그대로 (사용자 확정).
                Positioned(
                  top: 0,
                  left: CarbonSpacing.s5,
                  right: CarbonSpacing.s5,
                  child: TopBar(
                    actions: [
                      // 새로운 시작 계산기를 맨 왼쪽에 (사용자 확정).
                      TopIconButton(
                        icon: Icons.calculate_outlined,
                        tooltip: tr('새로운 시작 계산기', 'A New Beginning Calculator'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NewBeginningScreen(),
                          ),
                        ),
                      ),
                      TopIconButton(
                        icon: Icons.article_outlined,
                        tooltip: tr('게임 룰 요약', 'Rules Summary'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RulesSummaryScreen(),
                          ),
                        ),
                      ),
                      TopIconButton(
                        icon: Icons.menu_book_outlined,
                        tooltip: tr('부서 도감', 'Department Guide'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DeptCatalogScreen(),
                          ),
                        ),
                      ),
                      TopIconButton(
                        icon: Icons.info_outline,
                        tooltip: tr('아이콘 참조표', 'Icon Reference'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const IconReferenceScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 한영 스위치: 오버라인 줄 높이(_homeHeaderTop)에 두고, 오른쪽
                // 끝선은 아이콘 참조표 아이콘 글리프(44px 버튼 안 22px →
                // 버튼 끝에서 13px)에 맞춘다 (사용자 확정). 아이콘 줄보다
                // 뒤에 둬서 터치가 스위치로 간다.
                Positioned(
                  top: _homeHeaderTop,
                  right: CarbonSpacing.s5 + _langSwitchInset,
                  child: CarbonContentSwitcher(
                    dense: true,
                    height: _langSwitchHeight,
                    segmentWidth: _langSegmentWidth,
                    labels: const ['KO', 'EN'],
                    selected: isEn ? 1 : 0,
                    onChanged: (i) {
                      // 언어는 즉시 바뀌고, 저장은 뒤에서 비동기로 끝난다.
                      setAppLang(i == 1 ? AppLang.en : AppLang.ko);
                      setState(() {});
                    },
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
                    'assets/pcount/p$players.webp',
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
                tr('타일 $removed개 제외', 'Remove $removed tiles'),
                style: CarbonText.body01.copyWith(
                  color: CarbonColors.supportError,
                ),
              ),
              Text(
                tr('$kept개 사용', '$kept tiles in play'),
                style: CarbonText.helperText01,
              ),
              Text(
                disksByPlayerCount[players]! > 0
                    ? tr(
                        '중립 디스크 ${disksByPlayerCount[players]}개',
                        '${disksByPlayerCount[players]} neutral disks',
                      )
                    : tr('중립 디스크 없음', 'No neutral disks'),
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
                        label: tr('부서 타일', 'Departments'),
                        icon: Icons.grid_view,
                        selected: _tab == 0,
                        onTap: () => setState(() => _tab = 0),
                      ),
                      _TabButton(
                        label: tr('중립 디스크', 'Disks'),
                        icon: Icons.circle,
                        selected: _tab == 1,
                        onTap: () => setState(() => _tab = 1),
                      ),
                      if (_result.playerCount == 2)
                        _TabButton(
                          label: tr('1인 도우미', 'Solo'),
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

  /// 결과 화면 공통 헤더: 제목 줄 + 요약 바.
  /// 다시 뽑기는 각 모드의 첫 섹션 헤더 우측 아이콘, 인원 변경은 뒤로가기.
  List<Widget> _deptHeaderChildren() {
    return [
      Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      tr(
                        '${playerLabel(_result.playerCount)} 게임',
                        playerLabel(_result.playerCount),
                      ),
                      style: CarbonText.heading05,
                    ),
                  ),
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
            labels: [tr('요약', 'Summary'), tr('상세', 'Details')],
            selected: _detail ? 1 : 0,
            onChanged: (i) => setState(() => _detail = i == 1),
          ),
        ],
      ),
      const SizedBox(height: CarbonSpacing.s5),
      _SummaryBar(result: _result),
      const SizedBox(height: CarbonSpacing.s5),
    ];
  }

  /// 확장 모드 종류 고르기 헤더 (요약·상세 공통).
  String get _chooseKindsTitle => tr('종류 고르기', 'Choose Departments');
  String get _chooseKindsSubtitle => tr(
    '아래 번호만 2장씩 꺼내기 — 나머지는 상자로',
    'Take both copies of these numbers only — return the rest to the box',
  );

  void _reroll() => setState(
    () => _result = _result.isExpansion
        ? drawExpansion(_result.playerCount)
        : draw(_result.playerCount),
  );

  /// 다시 뽑기: 사각 테두리 아이콘 버튼 (섹션 헤더 우측용).
  /// [onTap]을 주지 않으면 부서 타일 다시 뽑기([_reroll])를 실행한다.
  Widget _rerollIconButton([VoidCallback? onTap]) {
    return Material(
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: CarbonColors.interactive),
      ),
      child: InkWell(
        onTap: onTap ?? _reroll,
        hoverColor: CarbonColors.interactiveTint,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.shuffle, size: 18, color: CarbonColors.interactive),
        ),
      ),
    );
  }

  /// 확장 요약: 종류 고르기(헤더 우측 다시 뽑기 아이콘) → 타일 제외를
  /// 세로로 배치 (사용자 확정 레이아웃).
  Widget _expansionSummaryTab(List<Department> shown) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(CarbonSpacing.s5),
          sliver: SliverList.list(
            children: [
              ..._deptHeaderChildren(),
              _diskSectionHeader(
                _chooseKindsTitle,
                _chooseKindsSubtitle,
                Icons.grid_view,
                trailing: _rerollIconButton(),
              ),
              const SizedBox(height: CarbonSpacing.s4),
              _KindCleanupCard(result: _result, onTapDept: _showDetail),
              const SizedBox(height: CarbonSpacing.s6),
              _diskSectionHeader(
                tr('타일 제외', 'Remove Tiles'),
                tr(
                  '꺼내 온 32장에서 아래 타일을 표시된 장수만큼 빼세요',
                  'From those 32 tiles, remove the tiles below in the quantities shown',
                ),
                Icons.archive_outlined,
              ),
            ],
          ),
        ),
        _deptGrid(shown),
        const SliverToBoxAdapter(child: SizedBox(height: CarbonSpacing.s8)),
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
          // 모든 모드에서 헤더 다음에 바로 섹션 헤더가 오므로 하단 여백은
          // 두지 않는다 (요약↔상세 전환 시 위치가 흔들리지 않게 동일 유지).
          padding: const EdgeInsets.fromLTRB(
            CarbonSpacing.s5,
            CarbonSpacing.s5,
            CarbonSpacing.s5,
            0,
          ),
          sliver: SliverList.list(children: _deptHeaderChildren()),
        ),
        if (!_detail) ...[
          // 기본판 요약: 확장과 같은 문법 — 섹션 헤더 우측에 다시 뽑기 아이콘.
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: CarbonSpacing.s5),
            sliver: SliverToBoxAdapter(
              child: _diskSectionHeader(
                tr('타일 제외', 'Remove Tiles'),
                tr(
                  '아래 타일을 표시된 장수만큼 상자에 되돌리세요',
                  'Return the tiles below to the game box in the quantities shown',
                ),
                Icons.archive_outlined,
                trailing: _rerollIconButton(),
              ),
            ),
          ),
          _deptGrid(shown),
        ] else ...[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: CarbonSpacing.s5),
            sliver: SliverList.list(
              children: _result.isExpansion
                  ? [
                      _diskSectionHeader(
                        _chooseKindsTitle,
                        _chooseKindsSubtitle,
                        Icons.grid_view,
                        trailing: _rerollIconButton(),
                      ),
                      const SizedBox(height: CarbonSpacing.s4),
                      _KindCleanupCard(result: _result, onTapDept: _showDetail),
                    ]
                  : [
                      _diskSectionHeader(
                        tr('전체 부서', 'All Departments'),
                        tr(
                          '16종 전체 — 사용·제외 상태 표시',
                          'All 16 Departments — in play / removed',
                        ),
                        Icons.grid_view,
                        trailing: _rerollIconButton(),
                      ),
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
                  // 흰색 카드 헤더 — 사용자 확정.
                  decoration: BoxDecoration(
                    color: CarbonColors.background,
                    border: Border(
                      // 타일 넘버 플레이트와 같은 유형 컬러.
                      left: BorderSide(color: deptTypeColorOf(type), width: 4),
                      top: const BorderSide(color: Color(0xFFE4E6E7)),
                      right: const BorderSide(color: Color(0xFFE4E6E7)),
                      bottom: const BorderSide(color: Color(0xFFE4E6E7)),
                    ),
                  ),
                  child: Row(
                    children: [
                      // 도감과 같은 공식 유형 아이콘 (참조표 i01~i04).
                      Image.asset(
                        'assets/reficons/i0${DeptType.values.indexOf(type) + 1}.webp',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: CarbonSpacing.s3),
                      Text(type.label, style: CarbonText.heading02),
                      const SizedBox(width: CarbonSpacing.s3),
                      Text(type.altLabel, style: CarbonText.helperText01),
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
              Text(
                tr('중립 디스크 없음', 'No Neutral Disks'),
                style: CarbonText.heading03,
              ),
              const SizedBox(height: CarbonSpacing.s3),
              Text(
                tr(
                  '1인 게임에서는 게임판에 미리 놓는 디스크가 없습니다',
                  'In a solo game, no disks are placed on the board in advance',
                ),
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
              Text(
                tr('중립 디스크를 사용하지 않습니다', 'No Neutral Disks Used'),
                style: CarbonText.heading03,
              ),
              const SizedBox(height: CarbonSpacing.s3),
              Text(
                tr(
                  '4인 게임에서는 이 과정을 생략합니다',
                  'For a 4-player game, skip this step.',
                ),
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
        Text(
          tr(
            '중립 디스크 ${_disks.totalDisks}개',
            '${_disks.totalDisks} Neutral Disks',
          ),
          style: CarbonText.heading05,
        ),
        const SizedBox(height: CarbonSpacing.s3),
        Text(
          tr(
            '게임에 참여하지 않는 색상의 디스크를 아래대로 게임판에 놓으세요.',
            'Place disks from an unused player color on the game board as shown below.',
          ),
          style: CarbonText.body01.copyWith(color: CarbonColors.textSecondary),
        ),
        const SizedBox(height: CarbonSpacing.s6),
        // 다시 뽑기는 부서 타일과 같은 형식 — 첫 섹션 헤더 우측 아이콘.
        _diskSectionHeader(
          tr('기부 차트', 'Donation Chart'),
          tr(
            '${_disks.donations.length}개 · 표시된 칸에 디스크 1개씩',
            '${_disks.donations.length} · 1 disk on each space shown',
          ),
          Icons.volunteer_activism_outlined,
          trailing: _rerollIconButton(
            () => setState(() => _disks = drawDisks(_result.playerCount)),
          ),
        ),
        const SizedBox(height: CarbonSpacing.s4),
        _DiskListCard(
          rows: [
            for (final code in ([..._disks.donations]..sort()))
              (
                code,
                tr(
                  '${donationRowName(code[0])} · ${code.substring(1)}번 칸',
                  '${donationRowName(code[0])} · space ${code.substring(1)}',
                ),
                1,
              ),
          ],
          showCount: false,
        ),
        const SizedBox(height: CarbonSpacing.s6),
        _diskSectionHeader(
          tr('도시 건설 부지', 'City Construction Spaces'),
          tr(
            '${_disks.cityTotal}개 · 각 도시의 가장 왼쪽 빈 건설 부지부터',
            '${_disks.cityTotal} · leftmost unoccupied construction space of each city first',
          ),
          Icons.location_city,
        ),
        for (final region in cityRegions.keys)
          if (cityRegions[region]!.any(_disks.cityDisks.containsKey)) ...[
            const SizedBox(height: CarbonSpacing.s4),
            _DiskListCard(
              title: regionName(region),
              titleColor: regionColors[region],
              rows: [
                for (final city in cityRegions[region]!)
                  if (_disks.cityDisks.containsKey(city))
                    (null, cityName(city), _disks.cityDisks[city]!),
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
        Text(tr('1인 도우미', 'Solo Aid'), style: CarbonText.heading05),
        const SizedBox(height: CarbonSpacing.s3),
        Text(
          tr(
            '앤드류 카네기를 상대하는 라운드 진행 요약입니다.',
            'A round-by-round summary for playing against Andrew Carnegie.',
          ),
          style: CarbonText.body01.copyWith(color: CarbonColors.textSecondary),
        ),
        const SizedBox(height: CarbonSpacing.s6),
        _diskSectionHeader(
          tr('라운드 진행', 'Round Sequence'),
          tr('5단계', '5 steps'),
          Icons.loop,
        ),
        const SizedBox(height: CarbonSpacing.s4),
        _DiskListCard(
          showCount: false,
          rows: [
            (
              '1',
              tr(
                '새 행동 카드 — 앤드류의 맨 위 카드를 보지 않고 0점 카드 아래 뒷면으로 놓기',
                "New Action Card — draw Andrew's top action card and, without looking at it, place it face-down below the 0 VP card",
              ),
              0,
            ),
            (
              '2',
              tr(
                '행동 선택 — 기관차 왼쪽: 플레이어가 선택 · 오른쪽: 카드를 공개해 앤드류가 선택',
                'Choice of Action — locomotive to the left: you choose · to the right: flip the action card face-up; Andrew chooses',
              ),
              0,
            ),
            (
              '3',
              tr(
                '앤드류의 차례 — 이벤트 처리 후 카드의 행동 해결',
                "Andrew's Turn — resolve the event, then resolve Andrew's action on the card",
              ),
              0,
            ),
            (
              '4',
              tr(
                '플레이어의 차례 — 이벤트(수입/기부) 해결 후 해당 종류 부서 사용',
                "Player's Turn — resolve events (Take Income / Make a Donation), then use your Departments of that type",
              ),
              0,
            ),
            (
              '5',
              tr(
                '라운드 종료 — 직원 활성화 → 행동 마커 1칸 전진 → 카드를 도달한 승점 카드 아래 뒷면으로 → 기관차를 반대편으로',
                "End of Round — activate employees → move the action marker 1 space right → place Andrew's card face-down under the VP card it has reached → move the locomotive to the other side",
              ),
              0,
            ),
          ],
        ),
        const SizedBox(height: CarbonSpacing.s6),
        _diskSectionHeader(
          tr('앤드류 행동 해결', "Resolve Andrew's Action"),
          tr(
            '불가 1건당 카드 1칸 오른쪽 이동',
            'Slide the card 1 space right for each one that cannot be done',
          ),
          Icons.smart_toy_outlined,
        ),
        const SizedBox(height: CarbonSpacing.s4),
        _DiskListCard(
          showCount: false,
          rows: [
            (
              null,
              tr(
                '인사 — 카드에 표시된 칸 수만큼 카드를 오른쪽으로 이동',
                'Human Resources — slide the action card to the right by the number of spaces indicated',
              ),
              0,
            ),
            (
              null,
              tr(
                '경영 — 표시된 종류의 부서 타일 1~3개 획득 (항상 가장 낮은 번호부터)',
                'Management — take 1-3 Department tiles of the type shown (always the lowest number available)',
              ),
              0,
            ),
            (
              null,
              tr(
                '건설 — 표시된 각 도시의 가장 왼쪽 건설 부지에 디스크 1개씩',
                'Construction — place a disk on the leftmost space of each city named on the card',
              ),
              0,
            ),
            (
              null,
              tr(
                'R&D — 표시된 지역의 운송 디스크를 1~3칸 오른쪽으로 이동',
                'R&D — move the transport disk in the region shown 1-3 spaces to the right',
              ),
              0,
            ),
          ],
        ),
        const SizedBox(height: CarbonSpacing.s6),
        _diskSectionHeader(
          tr('이벤트 (앤드류)', 'Events (Andrew)'),
          '',
          Icons.event_note_outlined,
        ),
        const SizedBox(height: CarbonSpacing.s4),
        _DiskListCard(
          showCount: false,
          rows: [
            (
              null,
              tr(
                '파견 칸 — 앤드류에게는 아무 일도 일어나지 않음',
                'Mission area space — nothing happens for Andrew',
              ),
              0,
            ),
            (
              null,
              tr(
                '기부 칸 — 카드 상단의 기부 칸에 디스크 1개 (칸이 차 있으면 생략) 후 카드를 오른쪽으로 1칸',
                'Donation symbol — place a disk on the donation space shown at the top of the card; if it is occupied (or Andrew is out of disks), place none and slide the card 1 space right',
              ),
              0,
            ),
          ],
        ),
        const SizedBox(height: CarbonSpacing.s6),
        _diskSectionHeader(
          tr('앤드류 점수 계산', "Andrew's Scoring"),
          tr('게임 종료 시', 'At the end of the game'),
          Icons.emoji_events_outlined,
        ),
        const SizedBox(height: CarbonSpacing.s4),
        _DiskListCard(
          showCount: false,
          rows: [
            (
              null,
              tr(
                '행동 카드 — 놓인 승점 카드의 점수만큼',
                'Action cards — the VP of the VP card each one is under',
              ),
              0,
            ),
            (null, tr('부서 타일 1개당 2점', '2 VP per Department tile'), 0),
            (
              null,
              tr(
                '운송 트랙 마지막 칸 도달 디스크 1개당 6점',
                '6 VP per transport disk that reached the last box of a transportation track',
              ),
              0,
            ),
            (
              null,
              tr(
                '건설 디스크 — 도시에 표시된 0~3점',
                'Construction disks — 0-3 VP each, as shown for each city',
              ),
              0,
            ),
            (
              null,
              tr(
                '기부 디스크 — 플레이어의 진행 기준으로 계산',
                'Donation disks — scored according to what you built',
              ),
              0,
            ),
          ],
        ),
        const SizedBox(height: CarbonSpacing.s8),
      ],
    );
  }

  Widget _diskSectionHeader(
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CarbonSpacing.s4,
        vertical: CarbonSpacing.s3,
      ),
      // 흰색 카드 헤더(컬러 바 + 옅은 보더) — 사용자 확정.
      decoration: const BoxDecoration(
        color: CarbonColors.background,
        border: Border(
          left: BorderSide(color: CarbonColors.interactive, width: 4),
          top: BorderSide(color: Color(0xFFE4E6E7)),
          right: BorderSide(color: Color(0xFFE4E6E7)),
          bottom: BorderSide(color: Color(0xFFE4E6E7)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
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
          ),
          if (trailing != null) ...[
            const SizedBox(width: CarbonSpacing.s3),
            trailing,
          ],
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
          // 흰색 카드로 밝게 — 상단 컬러 바만 유지 (사용자 요청: 어두움 해소).
          decoration: BoxDecoration(
            color: CarbonColors.background,
            border: Border(
              top: BorderSide(color: color, width: 4),
              left: const BorderSide(color: Color(0xFFE4E6E7)),
              right: const BorderSide(color: Color(0xFFE4E6E7)),
              bottom: const BorderSide(color: Color(0xFFE4E6E7)),
            ),
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
            tr('사용할 종류', 'Departments Used'),
            result.selectedKinds!.length,
            CarbonColors.supportSuccess,
            Icons.grid_view,
          ),
          const SizedBox(width: CarbonSpacing.s3),
          stat(
            tr('제외할 타일', 'Tiles to Remove'),
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
          tr('상자에 되돌릴 타일', 'Return to Box'),
          result.totalRemoved,
          CarbonColors.supportError,
          Icons.archive_outlined,
        ),
        const SizedBox(width: CarbonSpacing.s3),
        stat(
          tr('테이블에 놓을 타일', 'Place on Table'),
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
                    width: isEn ? 104 : 64,
                    child: Text(
                      type.label,
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
      text: type.label,
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
                      Text(dept.name, style: CarbonText.heading03),
                      const SizedBox(height: 2),
                      Text(dept.altName, style: CarbonText.helperText01),
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
                  CarbonTag(
                    text: tr('확장', 'Expansion'),
                    bg: CarbonColors.tagGrayBg,
                    fg: CarbonColors.tagGrayText,
                  ),
                if (dept.ongoing)
                  CarbonTag(
                    text: tr('지속 효과', 'Ongoing'),
                    bg: CarbonColors.tagAccentBg,
                    fg: CarbonColors.tagAccentText,
                  ),
                if (dept.endgame)
                  CarbonTag(
                    text: tr('게임 종료', 'Final Scoring'),
                    bg: CarbonColors.tagAccentBg,
                    fg: CarbonColors.tagAccentText,
                  ),
                if (boxed)
                  CarbonTag(
                    text: tr('이번 게임 미사용', 'Not in this game'),
                    bg: CarbonColors.tagGrayBg,
                    fg: CarbonColors.tagGrayText,
                  )
                else ...[
                  if (removedCount > 0)
                    CarbonTag(
                      text: tr('$removedCount장 제외', 'Remove $removedCount'),
                      bg: CarbonColors.tagRedBg,
                      fg: CarbonColors.tagRedText,
                    ),
                  if (kept > 0)
                    CarbonTag(
                      text: tr('$kept장 사용', '$kept in play'),
                      bg: CarbonColors.tagGreenBg,
                      fg: CarbonColors.tagGreenText,
                    ),
                ],
              ],
            ),
            const SizedBox(height: CarbonSpacing.s5),
            Text(tr('규칙', 'Rules'), style: CarbonText.label01),
            const SizedBox(height: CarbonSpacing.s2),
            Text(dept.ruleText, style: CarbonText.body02),
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
                      text: tr(
                        '${row.$3}개',
                        row.$3 == 1 ? '1 disk' : '${row.$3} disks',
                      ),
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

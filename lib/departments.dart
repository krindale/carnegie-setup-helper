import 'dart:math';

import 'l10n.dart';

/// The four Carnegie action types a department belongs to.
enum DeptType {
  hr('인사', 'Human Resources'),
  management('경영', 'Management'),
  construction('건설', 'Construction'),
  rnd('연구개발', 'R&D');

  const DeptType(this.ko, this.en);
  final String ko;
  final String en;

  /// 현재 언어의 유형 이름과, 보조 표기로 쓰는 다른 언어 이름.
  String get label => tr(ko, en);
  String get altLabel => tr(en, ko);
}

class Department {
  const Department({
    required this.number,
    required this.ko,
    required this.en,
    required this.type,
    required this.rule,
    required this.ruleEn,
    this.ongoing = false,
    this.expansion = false,
    this.endgame = false,
  });

  final int number;
  final String ko;
  final String en;
  final DeptType type;
  final String rule;

  /// 영문 규칙 설명 (영문 규칙서 16–17쪽, 확장 룰북 2–3쪽).
  final String ruleEn;

  /// 현재 언어의 부서 이름·규칙과, 보조 표기로 쓰는 다른 언어 이름.
  String get name => tr(ko, en);
  String get altName => tr(en, ko);
  String get ruleText => tr(rule, ruleEn);

  /// Tiles 4, 8, 12, 16 have a different color and provide ongoing effects.
  /// 확장 세트 3(19, 23, 27, 31)도 지속 효과를 제공합니다.
  final bool ongoing;

  /// 확장 #1 부서(17~32).
  final bool expansion;

  /// 확장 세트 4(20, 24, 28, 32): 게임 종료 시 이 부서에 활성화된 직원이
  /// 있으면 최종 득점에 영향을 주는 부서.
  final bool endgame;

  /// 규칙서 16–17쪽(1~16), 확장 룰북 2–3쪽(17~32)에서 추출한 원본 타일 이미지.
  String get image =>
      'assets/departments/dept_${number.toString().padLeft(2, '0')}.webp';
}

const departments = <Department>[
  Department(
    number: 1,
    ko: '훈련과 파트너십',
    en: 'Training and Partnerships',
    type: DeptType.hr,
    rule:
        '이 부서에서 활성화된 직원 1명을 파견합니다. 그런 다음, \$8를 받거나 '
        '직원을 최대 8회 이동시킬 수 있습니다.',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission. Then, the player may choose to receive '
        'either \$8 OR 8 employee moves.',
  ),
  Department(
    number: 2,
    ko: '채용',
    en: 'Recruiting',
    type: DeptType.hr,
    rule:
        '사용할 때마다 선택합니다: 활성화된 직원 1명을 파견한 뒤 새 직원 1명을 '
        '회사 로비에 놓거나, 직원을 최대 4회 이동시킵니다.',
    ruleEn:
        'For each use of this Department, the player may either: send an '
        'active employee from this Department on a Mission, then immediately '
        'place a new employee from their supply into their Company\'s Lobby, '
        'OR receive 4 employee moves.',
  ),
  Department(
    number: 3,
    ko: '안전과 품질',
    en: 'Safety and Quality',
    type: DeptType.hr,
    rule:
        '활성화된 직원 1명을 파견합니다. 그런 다음, 회사에 활성화된 직원 2명당 '
        '승점 1점(올림)을 얻습니다. 파견 나간 직원은 세지 않습니다.',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission. Then, the player receives 1 VP for '
        'every two active employees in their Company, rounded up. Employees '
        'on Missions are not considered to be active.',
  ),
  Department(
    number: 4,
    ko: '새로운 로비',
    en: 'New Lobby',
    type: DeptType.hr,
    ongoing: true,
    rule:
        '조직할 때 일반 비용에 추가로 상품 큐브 2개를 지불합니다. 이후 새 직원과 '
        '복귀 직원을 두 로비 중 원하는 곳에 배치할 수 있습니다. '
        '활성화된 직원 없이도 효과가 적용되는 유일한 부서입니다.',
    ruleEn:
        'To build this Department, the player must pay 2 goods cubes in '
        'addition to the normal building cost. Once built, it can hold new '
        'recruits and returning employees, which can be allocated between the '
        'two Lobbies as desired. It is the only Department that does not '
        'require an active employee to function.',
  ),
  Department(
    number: 5,
    ko: '구매',
    en: 'Purchasing',
    type: DeptType.management,
    rule:
        '활성화된 직원 1명을 파견합니다. 그런 다음, \$8를 받거나 '
        '상품 큐브 3개를 가져옵니다.',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission; they may then either receive \$8 OR '
        'take 3 goods cubes from the supply.',
  ),
  Department(
    number: 6,
    ko: '판매',
    en: 'Sales',
    type: DeptType.management,
    rule: '상품 큐브를 1~3개 공급처에 지불합니다. 지불한 상품 큐브마다 \$6를 받습니다.',
    ruleEn:
        'Each time a player uses this Department, they may pay 1 to 3 goods '
        'cubes to the supply. For each cube paid in this way, they receive '
        '\$6.',
  ),
  Department(
    number: 7,
    ko: '물류',
    en: 'Logistics',
    type: DeptType.management,
    rule:
        '상품 큐브를 1~3개 공급처에 지불합니다. 지불한 상품 큐브마다 '
        '\$3와 승점 1점을 얻습니다.',
    ruleEn:
        'Each time a player uses this Department, they may pay 1 to 3 goods '
        'cubes to the supply. For each cube paid in this way, they receive '
        '\$3 and 1 VP.',
  ),
  Department(
    number: 8,
    ko: '자산 관리',
    en: 'Property Management',
    type: DeptType.management,
    ongoing: true,
    rule:
        '지속 효과: 회사에 새로운 부서를 추가할 때마다, 직원 1명(활성/비활성)을 '
        '즉시 새 부서로 이동시킬 수 있습니다(비활성 상태로 놓임).',
    ruleEn:
        'Ongoing effect: whenever a player adds a new Department to their '
        'Company, they may immediately move one of their employees (active or '
        'inactive) to the new Department, in an inactive state.',
  ),
  Department(
    number: 9,
    ko: '건설',
    en: 'Engineering',
    type: DeptType.construction,
    rule:
        '활성화된 직원 1명을 파견합니다. 그런 다음, 상품 큐브 1~2개를 지불하고 '
        '파견한 지역에 새로운 프로젝트 1개를 짓습니다.',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission. That player then pays 1 or 2 goods '
        'cubes to build a new project in the same region.',
  ),
  Department(
    number: 10,
    ko: '위탁 건설',
    en: 'Construction Outsourcing',
    type: DeptType.construction,
    rule:
        '\$3와 상품 큐브 1~2개를 지불하면, 직원을 파견하지 않고도 게임판 어디에든 '
        '새로운 프로젝트 1개를 지을 수 있습니다.',
    ruleEn:
        'Whenever this Department is used, the player may pay \$3 and 1-2 '
        'goods cubes to build a new project anywhere on the game board, '
        'without sending an employee on a Mission.',
  ),
  Department(
    number: 11,
    ko: '공급망',
    en: 'Supply Chain',
    type: DeptType.construction,
    rule: '상품 큐브 1~3개를 1개당 \$1에 구입할 수 있습니다.',
    ruleEn:
        'Whenever a player uses this Department, they may purchase up to 3 '
        'goods cubes at a cost of \$1 each.',
  ),
  Department(
    number: 12,
    ko: '커뮤니케이션',
    en: 'Communications',
    type: DeptType.construction,
    ongoing: true,
    rule:
        '지속 효과: 활성화된 직원 1명이 있는 동안, 기부 비용이 \$5가 아닌 '
        '\$3를 기준으로 계산됩니다.',
    ruleEn:
        'Ongoing effect: as long as this Department contains an active '
        'employee, the costs of the player\'s new donations are calculated on '
        'the basis of \$3 per donation, rather than \$5.',
  ),
  Department(
    number: 13,
    ko: '고급 연구',
    en: 'Advanced Research',
    type: DeptType.rnd,
    rule: '활성화된 직원 1명을 파견합니다. 그런 다음, 연구 점수 7점을 얻습니다.',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission; the player then gains 7 study points.',
  ),
  Department(
    number: 14,
    ko: '고급 설계',
    en: 'Advanced Design',
    type: DeptType.rnd,
    rule: '이 부서의 활성화된 직원 1명당 연구 점수 4점을 얻습니다.',
    ruleEn:
        'Whenever this Department is used, its owner gains 4 study points for '
        'each active employee in the Department.',
  ),
  Department(
    number: 15,
    ko: '자선 기부',
    en: 'Charitable Giving',
    type: DeptType.rnd,
    rule:
        '활성화된 직원 1명을 파견하고 기부 비용을 지불한 뒤, 자신의 기부 디스크를 '
        '다른 플레이어의 기부 디스크 위에 놓습니다. 같은 기부는 2번 할 수 없습니다.',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission. After paying the donation cost, the '
        'player places one of their disks on top of another player\'s donation '
        'disk. A player may not make the same donation twice.',
  ),
  Department(
    number: 16,
    ko: '전신 기사',
    en: 'Telegraph Operators',
    type: DeptType.rnd,
    ongoing: true,
    rule:
        '지속 효과: 활성화된 직원 1명이 있는 동안, 운송수단 트랙을 전진시키는 '
        '연구 점수 비용이 1 감소합니다(최소 1).',
    ruleEn:
        'Ongoing effect: as long as this Department contains an active '
        'employee, the player\'s study point costs to progress along '
        'transportation tracks are reduced by 1 (to a minimum of 1).',
  ),
];

/// 확장 #1 "새로운 부서" 16종 (확장 룰북 2–3쪽).
/// 세트 1(17, 21, 25, 29) 파견형 · 세트 2(18, 22, 26, 30) 지역 선택형 ·
/// 세트 3(19, 23, 27, 31) 지속 효과 · 세트 4(20, 24, 28, 32) 게임 종료 득점.
const expansionDepartments = <Department>[
  Department(
    number: 17,
    ko: '인사 행정',
    en: 'Human Resources Administration',
    type: DeptType.hr,
    expansion: true,
    rule:
        '이 부서에서 활성화된 직원 1명을 파견합니다. 그런 다음, 회사의 인사 부서 '
        '1개당(시작 부서 포함) 회사 안의 직원 1명을 원하는 다른 칸으로 이동시킬 수 '
        '있습니다. 이렇게 이동한 직원은 비활성 상태가 됩니다.',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission. Then, for each Human Resources '
        'Department in their Company (including the starting Department), '
        'they may move one employee on their Company board to any other '
        'location within their Company. An employee moved this way becomes '
        'inactive.',
  ),
  Department(
    number: 18,
    ko: '지역 파트너',
    en: 'Local Partners',
    type: DeptType.hr,
    expansion: true,
    rule:
        '지도에서 지역 1곳을 선택합니다. 그 지역에 지은 자신의 프로젝트 1개당 '
        '\$2를 받거나 직원을 2회 이동시킵니다.',
    ruleEn:
        'The player chooses a single region of the map. For each project they '
        'have built in that region, they receive either \$2 OR 2 employee '
        'moves.',
  ),
  Department(
    number: 19,
    ko: '사내 커뮤니케이션',
    en: 'Corporate Communication',
    type: DeptType.hr,
    expansion: true,
    ongoing: true,
    rule:
        '지속 효과: 턴 시작 시 이 부서에 활성화된 직원이 있으면, 그 턴 동안 '
        '회사 안에서 직원을 대각선 방향으로도 이동시킬 수 있습니다.',
    ruleEn:
        'Ongoing effect: if this Department contains an active employee at '
        'the beginning of the turn, the player\'s employees may move '
        'diagonally or orthogonally within their Company for the duration of '
        'that turn.',
  ),
  Department(
    number: 20,
    ko: '녹지 공간',
    en: 'Green Spaces',
    type: DeptType.hr,
    expansion: true,
    endgame: true,
    rule:
        '게임 종료 시 이 부서에 활성화된 직원이 있으면, 회사 보드에서 부서가 없는 '
        '빈칸 1개당 승점 2점을 얻습니다.',
    ruleEn:
        'If this Department contains an active employee at the end of the '
        'game, the player scores 2 VP for each space on their Company board '
        'that does not contain a Department.',
  ),
  Department(
    number: 21,
    ko: '회계',
    en: 'Accounting',
    type: DeptType.management,
    expansion: true,
    rule:
        '이 부서에서 활성화된 직원 1명을 파견합니다. 그런 다음, 회사의 경영 부서 '
        '1개당(시작 부서 포함) \$3를 받습니다.',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission. The player then receives \$3 for each '
        'Management Department in their Company (including starting '
        'Departments).',
  ),
  Department(
    number: 22,
    ko: '브랜딩',
    en: 'Branding',
    type: DeptType.management,
    expansion: true,
    rule:
        '지도에서 지역 1곳을 선택합니다. 그 지역에 지은 자신의 프로젝트 1개당 '
        '\$2를 받거나 상품 큐브 1개를 가져옵니다.',
    ruleEn:
        'The player chooses a single region of the map. For each project they '
        'have built in that region, they receive either \$2 OR 1 goods cube.',
  ),
  Department(
    number: 23,
    ko: '급여 관리',
    en: 'Payroll Management',
    type: DeptType.management,
    expansion: true,
    ongoing: true,
    rule:
        '지속 효과: 활성화된 직원 1명이 있는 동안(그 직원이 활성화된 라운드는 '
        '제외), 회사에서 직원을 활성화할 때 명시된 비용 대신 \$2를 더 내고 승점 '
        '1점을 얻거나, 비용과 무관하게 \$1만 내고 승점 1점을 잃을 수 있습니다'
        '(승점이 0 이하면 불가).',
    ruleEn:
        'Ongoing effect while this Department contains an active employee '
        '(not in the round that employee was activated): when activating an '
        'employee anywhere in their Company, the player may pay \$2 more than '
        'the listed price and gain 1 VP, OR pay \$1 regardless of price and '
        'lose 1 VP (not allowed with 0 or fewer VP).',
  ),
  Department(
    number: 24,
    ko: '홍보',
    en: 'Public Relations',
    type: DeptType.management,
    expansion: true,
    endgame: true,
    rule:
        '게임 종료 시 이 부서에 활성화된 직원이 있으면, 자신이 선택한 지역 1곳에 '
        '지은 프로젝트 1개당 승점 2점을 얻습니다.',
    ruleEn:
        'If this Department contains an active employee at the end of the '
        'game, the player gains 2 VP for each project they have built in a '
        'single region of their choice.',
  ),
  Department(
    number: 25,
    ko: '생산 라인',
    en: 'Production Lines',
    type: DeptType.construction,
    expansion: true,
    rule:
        '이 부서에서 활성화된 직원 1명을 파견합니다. 그런 다음, 회사의 건설 부서 '
        '1개당(시작 부서 포함) 상품 큐브 1개를 가져옵니다.',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission. The player then receives 1 goods cube '
        'for each Construction Department in their Company (including the '
        'starting Department).',
  ),
  Department(
    number: 26,
    ko: '리노베이션',
    en: 'Renovation',
    type: DeptType.construction,
    expansion: true,
    rule:
        '지도에서 지역 1곳을 선택합니다. 그 지역에 지은 자신의 프로젝트 1개당 '
        '\$2를 받거나 승점 1점을 얻습니다.',
    ruleEn:
        'The player chooses a single region of the map. For each project they '
        'have built in that region, they receive either \$2 OR 1 VP.',
  ),
  Department(
    number: 27,
    ko: '정치 로비',
    en: 'Political Lobbying',
    type: DeptType.construction,
    expansion: true,
    ongoing: true,
    rule:
        '지속 효과: 활성화된 직원 1명이 있는 동안, 선택한 프로젝트 종류와 '
        '일치하지 않는 칸에도 지을 수 있습니다. 소도시에 짓거나 일치하는 칸에 '
        '지으면 승점 1점을 얻습니다.',
    ruleEn:
        'Ongoing effect: as long as this Department contains an active '
        'employee, the player may build on spaces that do not match the '
        'chosen project type. If the player builds in a small town, or on a '
        'space that matches the chosen project type, they gain 1 VP.',
  ),
  Department(
    number: 28,
    ko: '우체국',
    en: 'Post Office',
    type: DeptType.construction,
    expansion: true,
    endgame: true,
    rule:
        '게임 종료 시 이 부서에 활성화된 직원이 있으면, 대도시 연결을 셀 때 연결 '
        '점수 1점을 더합니다(최대 6점). 연결 점수 6점으로 게임을 마치면 보너스 '
        '승점 9점을 추가로 얻습니다.',
    ruleEn:
        'If this Department contains an active employee at the end of the '
        'game, the player may add 1 connection point when counting '
        'connections between major cities (to a maximum of 6). Finishing with '
        '6 connection points gives a bonus of 9 VP.',
  ),
  Department(
    number: 29,
    ko: '연구개발 조정',
    en: 'R&D Coordination',
    type: DeptType.rnd,
    expansion: true,
    rule:
        '이 부서에서 활성화된 직원 1명을 파견합니다. 그런 다음, 회사의 연구개발 '
        '부서 1개당(시작 부서 포함) 연구 점수 2점을 얻습니다.',
    ruleEn:
        'To use this Department, the player must send an active employee from '
        'this Department on a Mission. The player then receives 2 study '
        'points for each R&D Department in their Company (including the '
        'starting Department).',
  ),
  Department(
    number: 30,
    ko: '지식 공유',
    en: 'Knowledge Sharing',
    type: DeptType.rnd,
    expansion: true,
    rule:
        '지도에서 지역 1곳을 선택합니다. 그 지역에 지은 자신의 프로젝트 1개당 '
        '\$2를 받거나 연구 점수 2점을 얻습니다.',
    ruleEn:
        'The player chooses a single region of the map. For each project they '
        'have built in that region, they receive either \$2 OR 2 study '
        'points.',
  ),
  Department(
    number: 31,
    ko: '기록 보관소',
    en: 'Archives',
    type: DeptType.rnd,
    expansion: true,
    ongoing: true,
    rule:
        '지속 효과: 활성화된 직원 1명이 있는 동안, 운송 수입을 받을 때 자기 디스크 '
        '위치보다 낮은 단계의 수입을 선택할 수 있습니다. 또한 운송수단 트랙의 '
        '마지막 칸이 다른 플레이어의 마커로 차 있어도 들어가서 트랙 끝 보너스를 '
        '받을 수 있습니다.',
    ruleEn:
        'Ongoing effects while this Department contains an active employee: '
        'when receiving transport income, the player may choose a lower level '
        'of income than their disk\'s position. Also, their transportation '
        'marker may enter the final box of each transportation track and '
        'receive the end-of-track bonus, even if it is occupied by other '
        'players\' markers.',
  ),
  Department(
    number: 32,
    ko: '도서관 네트워크',
    en: 'Network of Libraries',
    type: DeptType.rnd,
    expansion: true,
    endgame: true,
    rule:
        '게임 종료 시 이 부서에 활성화된 직원이 있으면, 자신이 프로젝트를 가장 '
        '적게 지은 지역에 지은 프로젝트 1개당 승점 4점을 얻습니다.',
    ruleEn:
        'If this Department contains an active employee at the end of the '
        'game, the player gains 4 VP for each project they built in the '
        'region in which they had built the fewest projects.',
  ),
];

/// 기본판 + 확장 전체 32종.
const allDepartments = <Department>[...departments, ...expansionDepartments];

/// Total copies of each department tile in the box.
const copiesPerDepartment = 2;

/// 규칙서 4쪽: 4/3/2인 게임에서는 부서 타일 4/8/16개를 무작위로 게임 상자에
/// 되돌려 놓습니다. 1인 게임 준비는 2인 게임과 동일합니다(규칙서 18쪽).
const removalByPlayerCount = <int, int>{1: 16, 2: 16, 3: 8, 4: 4};

class DrawResult {
  DrawResult(this.playerCount, this.removed) : selectedKinds = null;

  DrawResult.expansion(
    this.playerCount,
    this.removed,
    Set<int> this.selectedKinds,
  );

  final int playerCount;

  /// Department number -> number of copies removed (0, 1, or 2).
  final Map<int, int> removed;

  /// 확장 모드에서 이번 게임에 사용하는 16종의 번호. null이면 기본판 모드.
  final Set<int>? selectedKinds;

  bool get isExpansion => selectedKinds != null;

  /// 이번 게임에 사용하는 부서 종류 목록(항상 16종).
  List<Department> get pool => selectedKinds == null
      ? departments
      : [
          for (final d in allDepartments)
            if (selectedKinds!.contains(d.number)) d,
        ];

  int removedOf(Department d) => removed[d.number] ?? 0;
  int keptOf(Department d) => copiesPerDepartment - removedOf(d);

  int get totalRemoved => removalByPlayerCount[playerCount]!;
  int get totalKept => pool.length * copiesPerDepartment - totalRemoved;
}

DrawResult draw(int playerCount, [Random? random]) {
  final rng = random ?? Random();
  final pool = [
    for (final d in departments)
      for (var i = 0; i < copiesPerDepartment; i++) d.number,
  ]..shuffle(rng);

  final removed = <int, int>{};
  for (final n in pool.take(removalByPlayerCount[playerCount]!)) {
    removed[n] = (removed[n] ?? 0) + 1;
  }
  return DrawResult(playerCount, removed);
}

/// 확장 룰북 2쪽 "새로운 부서" 준비: 부서 타일을 유형별로 나눠 유형마다
/// 서로 다른 4종을 무작위로 뽑고(기본판+확장 8종 중), 뽑힌 종류의 페어로
/// 32장을 구성한 뒤 기본 규칙대로 인원수별 제외를 적용합니다.
DrawResult drawExpansion(int playerCount, [Random? random]) {
  final rng = random ?? Random();
  final selected = <int>{};
  for (final type in DeptType.values) {
    final kinds = [
      for (final d in allDepartments)
        if (d.type == type) d.number,
    ]..shuffle(rng);
    selected.addAll(kinds.take(4));
  }

  final pool = [
    for (final n in selected)
      for (var i = 0; i < copiesPerDepartment; i++) n,
  ]..shuffle(rng);

  final removed = <int, int>{};
  for (final n in pool.take(removalByPlayerCount[playerCount]!)) {
    removed[n] = (removed[n] ?? 0) + 1;
  }
  return DrawResult.expansion(playerCount, removed, selected);
}

import 'dart:math';

/// The four Carnegie action types a department belongs to.
enum DeptType {
  hr('인사', 'Human Resources'),
  management('경영', 'Management'),
  construction('건설', 'Construction'),
  rnd('연구개발', 'R&D');

  const DeptType(this.ko, this.en);
  final String ko;
  final String en;
}

class Department {
  const Department({
    required this.number,
    required this.ko,
    required this.en,
    required this.type,
    required this.rule,
    this.ongoing = false,
  });

  final int number;
  final String ko;
  final String en;
  final DeptType type;
  final String rule;

  /// Tiles 4, 8, 12, 16 have a different color and provide ongoing effects.
  final bool ongoing;

  String get image =>
      'assets/departments/dept_${number.toString().padLeft(2, '0')}.png';
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
  ),
  Department(
    number: 2,
    ko: '채용',
    en: 'Recruiting',
    type: DeptType.hr,
    rule:
        '사용할 때마다 선택합니다: 활성화된 직원 1명을 파견한 뒤 새 직원 1명을 '
        '회사 로비에 놓거나, 직원을 최대 4회 이동시킵니다.',
  ),
  Department(
    number: 3,
    ko: '안전과 품질',
    en: 'Safety and Quality',
    type: DeptType.hr,
    rule:
        '활성화된 직원 1명을 파견합니다. 그런 다음, 회사에 활성화된 직원 2명당 '
        '승점 1점(올림)을 얻습니다. 파견 나간 직원은 세지 않습니다.',
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
  ),
  Department(
    number: 5,
    ko: '구매',
    en: 'Purchasing',
    type: DeptType.management,
    rule:
        '활성화된 직원 1명을 파견합니다. 그런 다음, \$8를 받거나 '
        '상품 큐브 3개를 가져옵니다.',
  ),
  Department(
    number: 6,
    ko: '판매',
    en: 'Sales',
    type: DeptType.management,
    rule: '상품 큐브를 1~3개 공급처에 지불합니다. 지불한 상품 큐브마다 \$6를 받습니다.',
  ),
  Department(
    number: 7,
    ko: '물류',
    en: 'Logistics',
    type: DeptType.management,
    rule:
        '상품 큐브를 1~3개 공급처에 지불합니다. 지불한 상품 큐브마다 '
        '\$3와 승점 1점을 얻습니다.',
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
  ),
  Department(
    number: 9,
    ko: '건설',
    en: 'Engineering',
    type: DeptType.construction,
    rule:
        '활성화된 직원 1명을 파견합니다. 그런 다음, 상품 큐브 1~2개를 지불하고 '
        '파견한 지역에 새로운 프로젝트 1개를 짓습니다.',
  ),
  Department(
    number: 10,
    ko: '위탁 건설',
    en: 'Construction Outsourcing',
    type: DeptType.construction,
    rule:
        '\$3와 상품 큐브 1~2개를 지불하면, 직원을 파견하지 않고도 게임판 어디에든 '
        '새로운 프로젝트 1개를 지을 수 있습니다.',
  ),
  Department(
    number: 11,
    ko: '공급망',
    en: 'Supply Chain',
    type: DeptType.construction,
    rule: '상품 큐브 1~3개를 1개당 \$1에 구입할 수 있습니다.',
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
  ),
  Department(
    number: 13,
    ko: '고급 연구',
    en: 'Advanced Research',
    type: DeptType.rnd,
    rule: '활성화된 직원 1명을 파견합니다. 그런 다음, 연구 점수 7점을 얻습니다.',
  ),
  Department(
    number: 14,
    ko: '고급 설계',
    en: 'Advanced Design',
    type: DeptType.rnd,
    rule: '이 부서의 활성화된 직원 1명당 연구 점수 4점을 얻습니다.',
  ),
  Department(
    number: 15,
    ko: '자선 기부',
    en: 'Charitable Giving',
    type: DeptType.rnd,
    rule:
        '활성화된 직원 1명을 파견하고 기부 비용을 지불한 뒤, 자신의 기부 디스크를 '
        '다른 플레이어의 기부 디스크 위에 놓습니다. 같은 기부는 2번 할 수 없습니다.',
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
  ),
];

/// Total copies of each department tile in the box.
const copiesPerDepartment = 2;

/// 규칙서 4쪽: 4/3/2인 게임에서는 부서 타일 4/8/16개를 무작위로 게임 상자에
/// 되돌려 놓습니다. 1인 게임 준비는 2인 게임과 동일합니다(규칙서 18쪽).
const removalByPlayerCount = <int, int>{1: 16, 2: 16, 3: 8, 4: 4};

class DrawResult {
  DrawResult(this.playerCount, this.removed);

  final int playerCount;

  /// Department number -> number of copies removed (0, 1, or 2).
  final Map<int, int> removed;

  int removedOf(Department d) => removed[d.number] ?? 0;
  int keptOf(Department d) => copiesPerDepartment - removedOf(d);

  int get totalRemoved => removalByPlayerCount[playerCount]!;
  int get totalKept => departments.length * copiesPerDepartment - totalRemoved;
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

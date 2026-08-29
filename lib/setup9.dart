import 'dart:math';

/// 규칙서 4쪽 세팅 9번 — 2/3인 게임에서 중립 색 디스크를 게임판에 배치.
/// 데이터 출처: CARNEGIE_SETUP_RANDOMIZER__V1.xlsx (1인 게임 카드 20장).
///
/// 절차: 카드를 무작위 순서로 1장씩 넘기며, 카드마다
/// ① 기부 차트의 표시된 칸에 디스크 1개 →
/// ② 카드의 도시마다 순서대로 디스크 1개(그 도시의 가장 왼쪽 빈 건설 부지)
/// 를 놓는다. 디스크 예산(2인 18개, 3인 9개)이 소진되면 즉시 중단한다
/// (카드 중간에 끊길 수 있음). 4인 게임은 이 과정을 생략한다.

class SetupCard {
  const SetupCard(this.donation, this.cities);

  /// 기부 차트 칸 코드 (예: 'B3' — 행 B, 3번째 칸).
  final String donation;
  final List<String> cities;
}

const setupCards = <SetupCard>[
  SetupCard('D4', ['샌프란시스코', '덴버']),
  SetupCard('D1', ['피츠버그', '보스턴', '올버니']),
  SetupCard('B5', ['시카고', '오마하']),
  SetupCard('B4', ['보스턴', '뉴욕']),
  SetupCard('B3', ['뉴올리언스', '애틀랜타']),
  SetupCard('D3', ['뉴올리언스', '애틀랜타', '휴스턴', '찰스턴']),
  SetupCard('B2', ['올버니', '뉴욕', '워싱턴 D.C.', '피츠버그']),
  SetupCard('B1', ['신시내티', '덜루스', '세인트루이스', '캔자스시티']),
  SetupCard('C5', ['뉴욕', '시카고', '뉴올리언스', '샌프란시스코']),
  SetupCard('C4', ['포틀랜드', '보이시', '덴버', '로스앤젤레스']),
  SetupCard('D5', ['캔자스시티', '시카고']),
  SetupCard('C3', ['샌안토니오', '멤피스', '댈러스']),
  SetupCard('C2', ['피츠버그', '뉴욕']),
  SetupCard('C1', ['파고', '세인트폴']),
  SetupCard('A5', ['샌프란시스코', '로스앤젤레스']),
  SetupCard('D2', ['샌프란시스코', '산타페']),
  SetupCard('A4', ['뉴올리언스', '휴스턴']),
  SetupCard('A3', ['보스턴', '워싱턴 D.C.']),
  SetupCard('A2', ['세인트루이스', '시카고']),
  SetupCard('A1', ['솔트레이크시티', '리노']),
];

/// 기부 차트 행 이름 (A~D).
const donationRows = <String, String>{
  'A': '교육 (Education)',
  'B': '인권 (Human Rights)',
  'C': '복지 (Welfare)',
  'D': '보건 (Health)',
};

/// 인원수별 중립 디스크 개수. 4인은 0 (생략).
const disksByPlayerCount = <int, int>{1: 0, 2: 18, 3: 9, 4: 0};

/// 게임판 지도의 지역별 도시 (규칙서 게임판 기준).
const cityRegions = <String, List<String>>{
  '서부': ['포틀랜드', '보이시', '리노', '솔트레이크시티', '샌프란시스코', '로스앤젤레스'],
  '중서부': ['파고', '덜루스', '세인트폴', '오마하', '덴버', '캔자스시티', '세인트루이스', '시카고', '신시내티'],
  '남부': ['산타페', '댈러스', '샌안토니오', '휴스턴', '멤피스', '뉴올리언스', '애틀랜타', '찰스턴'],
  '동부': ['피츠버그', '워싱턴 D.C.', '올버니', '뉴욕', '보스턴'],
};

class DiskSetup {
  DiskSetup(this.playerCount, this.donations, this.cityDisks);

  final int playerCount;

  /// 배치 순서대로의 기부 차트 칸 코드.
  final List<String> donations;

  /// 도시 → 놓을 디스크 개수 (배치 순서 유지).
  final Map<String, int> cityDisks;

  int get totalDisks => disksByPlayerCount[playerCount]!;
  int get cityTotal => cityDisks.values.fold(0, (a, b) => a + b);
}

DiskSetup drawDisks(int playerCount, [Random? random]) {
  final rng = random ?? Random();
  var budget = disksByPlayerCount[playerCount]!;
  final donations = <String>[];
  final cityDisks = <String, int>{};
  if (budget == 0) return DiskSetup(playerCount, donations, cityDisks);

  final deck = [...setupCards]..shuffle(rng);
  for (final card in deck) {
    if (budget <= 0) break;
    donations.add(card.donation);
    budget--;
    for (final city in card.cities) {
      if (budget <= 0) break;
      cityDisks[city] = (cityDisks[city] ?? 0) + 1;
      budget--;
    }
  }
  return DiskSetup(playerCount, donations, cityDisks);
}

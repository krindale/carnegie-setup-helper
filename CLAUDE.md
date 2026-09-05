# CLAUDE.md

카네기(Carnegie) 보드게임 셋업 도우미 Flutter 앱. Android / iOS / 웹 지원.

## 기본 방침 (모든 작업에 최우선 적용)

0. **커밋·푸시는 명시적 지시가 있을 때만 한다.** 특히 main 푸시는 GitHub
   Pages 공개 배포를 자동 트리거하므로 절대 임의로 하지 않는다. 사용자
   확인용은 로컬 웹 서빙(`build/web` + `python -m http.server`, 매번 새
   포트)으로 보여준다.
0-1. **앱 UI에 "규칙서"라는 표현이나 쪽수 인용을 노출하지 않는다.** 근거
   인용(규칙서 n쪽)은 이 문서와 코드 주석에만 남긴다.

1. **규칙·사실은 단정하지 않는다.** 게임 규칙 등 사실을 말할 때는 반드시
   규칙서 원문을 인용해 근거와 함께 제시한다. 오독 사례: 1인 게임도 세팅 9의
   중립 디스크 18개를 배치한다 — 앤드류가 건너뛰는 것은 세팅 10뿐이다.
2. **명시적으로 지시받은 것만 수정한다.** "확인해봐"는 확인·보고까지다.
   명백히 옳아 보이는 수정이라도 먼저 보고하고 승인을 기다린다.
   지시받지 않은 레이아웃 재구성·요소 추가 금지.
3. **검수 없이 내보내지 않는다.** 설치·배포 전에 결과물(화면, 이미지, 동작)을
   직접 확인하고, 통과한 것만 내보낸다.

## 빌드 (중요: Windows 한글 경로 문제)

프로젝트가 한글 경로(`바탕 화면`) 아래에 있으면 Flutter 셰이더 컴파일러
(impellerc)가 크래시한다. **반드시 ASCII 매핑 드라이브에서 빌드할 것:**

```bat
subst X: "C:\Users\wow32\OneDrive\바탕 화면\canegie-department"
```

표준 검증·배포 루틴 (bash, `X:` = `/x`):

```sh
cd /x/carnegie_departments
dart format lib && flutter analyze && flutter test
flutter build web && flutter build apk --release
"C:\Users\wow32\AppData\Local\Android\Sdk\platform-tools\adb.exe" install -r build/app/outputs/flutter-apk/app-release.apk
```

- 사용자 확인용 설치는 항상 **릴리즈 APK** (디버그는 스크롤이 버벅임).
- 웹 확인: **`flutter build web --pwa-strategy=none`으로 빌드**(서비스 워커
  제거)하고 `build/web`을 **고정 포트 7777** 하나로만 서빙할 것
  (`python -m http.server 7777`). 이미 서버가 떠 있으면 재사용한다 —
  포트를 매번 바꾸지 말 것 (사용자 지시, 2026-09-06). 과거의 "매번 새 포트"
  규칙은 서비스 워커 캐시 때문이었고, pwa-strategy=none으로 원인이 제거됨.
  서빙 전 남은 서버 정리는 PowerShell로 python http.server 리스너를 종료.
- UI 시안(HTML 목업)도 **고정 포트 7778** 하나로만 서빙한다 (사용자 지시).
  시안 파일은 한 폴더에 모아 두고 같은 서버를 재사용하며, 확인용 탭은
  사용자가 볼 수 있게 열어 둔다.
- 타일 디자인 변경 시 골든 재생성:
  `flutter test --update-goldens test/dept_tile_golden_test.dart`.
  위젯 테스트에서 폰트 로드는 setUpAll에서 해야 한다 (testWidgets 본문은
  FakeAsync 존이라 실제 파일 I/O가 완료되지 않아 데드락). 같은 이유로
  골든에는 에셋 이미지가 비어 보인다 (레이아웃 검증용).

## 코드 구조

- `lib/main.dart` — 앱/테마, 게임 준비 화면, 결과 화면(탭: 부서 타일 / 중립
  디스크 / 1인 도우미), 요약 바, 상세 시트, 디스크 목록 카드. 결과 그리드는
  타일 자체가 셀이다 (카드 껍데기 없음, 상태 배지만 오버레이)
- `lib/dept_tile.dart` — 부서 타일 컴포넌트. 재사용 부품:
  `DeptNumberPlate`(유형 컬러 플레이트) · `DeptDoubleRule`(이중 괘선) ·
  `DeptEmblem`(중앙 이미지/엠블럼) · `DeptEffectBar`(효과 요약 바) ·
  `deptTypeColor/Of`, `deptTypeIcon`. `DeptTile`은 이 부품들을 기준 폭 400px
  시안 대비 **비례값**으로 조립 (FittedBox 축소 금지 — 사용자 확정).
  상세 시트·도감도 같은 부품을 화면 폭에 맞게 직접 배치한다 (미니 타일 금지).
  유형 4색: 인사 #846A6A / 경영 #8A7A4F / 건설 #6D7D62 / 연구개발 #7D6880 —
  섹션 헤더 좌측 바도 이 색을 따른다.
  현재 `DeptEmblem`은 원본 타일 이미지를 표시(하이브리드) — 아이콘 메달
  조합 코드는 바로 아래 dead_code로 보존, 스토어용 전환 시 복원.
- `lib/carbon.dart` — 디자인 토큰(CarbonColors/Text/Spacing)과 공용 위젯
  (CarbonButton, CarbonTag, CarbonContentSwitcher, TopBar, TopIconButton)
- `lib/departments.dart` — 부서 32종 데이터(기본 1~16 + 확장 17~32,
  `expansion`/`endgame` 필드), 인원별 제외 수
  (`removalByPlayerCount`: 1인=16, 2인=16, 3인=8, 4인=4), `draw()`,
  `drawExpansion()`(유형별 8종 중 4종 → 페어 32장 → 기본 제외 규칙,
  확장 룰북 2쪽)
- `lib/new_beginning.dart` — 확장 "새로운 시작" 입찰 시트 계산기
  (시트 수치는 확장 룰북 1쪽에서 검증: 큐브 2~6=$6/9/12/15/18,
  로비 직원 3무료~7=$32, 승점 -6=+$12~+6=$12, 이동 4~10=$5/8/10/15/20,
  총합≤$50)
- `lib/setup9.dart` — 세팅 9(중립 디스크) 카드 20장 데이터, 지역별 도시
  (`cityRegions`), `drawDisks()` (1인/4인 = 0개)
- `lib/reference.dart` — 부서 도감, 아이콘 참조표 화면

## 디자인 규칙 (사용자 확정 사항 — 지킬 것)

- 팔레트: `#EEF0F2`(배경) `#DADCDB`(레이어) `#C6C7C4`(보더) `#A2999E`(헬퍼)
  `#846A6A`(인터랙티브) `#353B3C`(텍스트). **파란색 버튼 절대 금지.**
- 색 톤 다운은 **색상 변경이 아니라 알파값**으로 (예: `0x99DA1E28`).
- 화면 전환: `CupertinoPageTransitionsBuilder` (커스텀 애니메이션 금지).
- 스크롤: `BouncingScrollPhysics` 전역 적용. 세로 화면 고정.
- 상단 바 없음 — 뒤로가기/액션 아이콘은 화면 모서리에 고정(TopBar).
- 텍스트는 좌측 정렬, **타일 이미지만 가운데 정렬**.
- 지시받은 요소만 수정할 것. 임의로 레이아웃을 재구성하면 안 됨.

## 에셋 파이프라인

에셋은 상위 폴더의 PDF에서 PyMuPDF로 추출했다 (`../카네기_규칙서.pdf`).

- `assets/departments/dept_01~16.png` — 규칙서 16–17쪽을 300dpi 클립 렌더링
  후 보더 플러드필로 배경 투명화. (임베디드 래스터는 탭이 잘려 있어 금지)
  현재 `DeptTile`의 중앙 엠블럼 슬롯에 표시된다 (그리드에서는 20% 확대 +
  위아래 여백). 저작권상 스토어 배포 불가 — 스토어행이면 아이콘 엠블럼으로
  전환하고 이 폴더를 번들에서 제외할 것.
- `assets/departments/dept_17~32.png` — 확장 룰북 2–3쪽. **임베디드 래스터
  금지(직사각형 원판)** — 페이지가 다이컷 테두리를 벡터로 덧그리므로 반드시
  300dpi 클립 렌더링 + 플러드필 투명화 (`../extract_expansion_tiles.py`).
- `assets/reficons/i01~47.png` — 규칙서 20쪽 아이콘 참조표. **원본 상대 크기
  유지**(공통 스케일), 캔버스 가로 180px 고정·세로는 실제 높이(행 높이 절약),
  180px 초과분만 축소. 순서: i09=활성 직원, i10=비활성 (스왑 이력 있음 주의).
- `assets/pcount/p1~4.png` — 규칙서 20쪽 게임 준비 참조표의 인원 아이콘
  (p1은 p2에서 앞사람만 크롭).
- `assets/icon/` — 앱 아이콘(규칙서 9쪽 인사 육각 아이콘).
  `dart run flutter_launcher_icons`로 재생성.
- 지역 색(규칙서 15쪽 배너): 서부 `#C2B49B` 중서부 `#C0503C` 남부 `#65A76B`
  동부 `#885F88` (`regionColors` in main.dart).

## UI 패턴 (사용자 확정)

- 섹션 헤더: **흰색 카드**(배경 #FFFFFF + 옅은 보더 #E4E6E7 + 좌측 컬러 바
  4px). 결과 화면·룰 요약·도감·계산기 공통. 요약 바 통계 카드도 흰색.
- **다시 뽑기 = 첫 섹션 헤더 우측의 사각 테두리 셔플 아이콘**(36px,
  `_rerollIconButton`). 부서 타일·중립 디스크 공통. 별도 버튼 줄 없음,
  인원 변경은 뒤로가기로 대체.
- 확장 요약 = "종류 고르기(유형별 사용 번호 칩, `_KindCleanupCard`) →
  타일 제외(유형→번호순 정렬 그리드)" 세로 2단계. 상세에도 종류 고르기 카드.
- 요약↔상세 전환 시 공통 요소(제목·요약 바·첫 헤더)의 위치가 흔들리면 안 됨
  (하단 여백을 모드 간 동일하게 유지).

## 게임 규칙 근거

- 부서 타일: 32개(16종×2) 중 4/3/2인 = 4/8/16개 무작위 제외 (규칙서 4쪽 세팅 4)
- 중립 디스크: 2/3인 = 18/9개. 카드마다 기부 1개 + 도시별 1개, 예산 소진 시
  카드 중간에도 즉시 중단 (세팅 9, 데이터: `../CARNEGIE_SETUP_RANDOMIZER__V1.xlsx`)
- 1인: 준비는 2인과 동일하되 **중립 디스크 배치 없음** (규칙서 18쪽).
  1인 도우미 탭 내용은 규칙서 18–19쪽 요약.
- 확장 "새로운 부서": 유형별로 8종 중 서로 다른 4종을 뽑아 페어 32장 구성 후
  기본 제외 규칙 적용 (확장 룰북 2쪽). 세트3(19·23·27·31)=지속,
  세트4(20·24·28·32)=게임 종료 득점(`endgame`). 원본 PDF:
  `../Carnegie-rules-EXPANSION-EN-WEB.pdf`

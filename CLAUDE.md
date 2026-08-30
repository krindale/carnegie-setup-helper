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
- 웹 확인: `build/web`을 `python -m http.server`로 서빙하되, **반드시 매번
  새 포트를 사용할 것** — Flutter 서비스 워커가 같은 오리진에서 이전 빌드를
  캐시로 서빙해 거짓 검증을 하게 된다 (실제 사고 이력 있음).
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
- `lib/departments.dart` — 부서 16종 데이터, 인원별 제외 수
  (`removalByPlayerCount`: 1인=16, 2인=16, 3인=8, 4인=4), `draw()`
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
- `assets/reficons/i01~47.png` — 규칙서 20쪽 아이콘 참조표. **원본 상대 크기
  유지**(공통 스케일), 캔버스 가로 180px 고정·세로는 실제 높이(행 높이 절약),
  180px 초과분만 축소. 순서: i09=활성 직원, i10=비활성 (스왑 이력 있음 주의).
- `assets/pcount/p1~4.png` — 규칙서 20쪽 게임 준비 참조표의 인원 아이콘
  (p1은 p2에서 앞사람만 크롭).
- `assets/icon/` — 앱 아이콘(규칙서 9쪽 인사 육각 아이콘).
  `dart run flutter_launcher_icons`로 재생성.
- 지역 색(규칙서 15쪽 배너): 서부 `#C2B49B` 중서부 `#C0503C` 남부 `#65A76B`
  동부 `#885F88` (`regionColors` in main.dart).

## 게임 규칙 근거

- 부서 타일: 32개(16종×2) 중 4/3/2인 = 4/8/16개 무작위 제외 (규칙서 4쪽 세팅 4)
- 중립 디스크: 2/3인 = 18/9개. 카드마다 기부 1개 + 도시별 1개, 예산 소진 시
  카드 중간에도 즉시 중단 (세팅 9, 데이터: `../CARNEGIE_SETUP_RANDOMIZER__V1.xlsx`)
- 1인: 준비는 2인과 동일하되 **중립 디스크 배치 없음** (규칙서 18쪽).
  1인 도우미 탭 내용은 규칙서 18–19쪽 요약.

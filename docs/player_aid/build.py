"""부서 플레이어 에이드(A4 가로 1쪽) 생성기.

lib/departments.dart 의 부서 데이터를 그대로 읽어 자기완결형 HTML 한 장을
만든다 (타일 이미지·폰트 base64 내장). 실행: python3 docs/player_aid/build.py
"""
import base64
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / 'lib' / 'departments.dart'
OUT = ROOT / 'docs' / 'player_aid' / 'carnegie_dept_player_aid.html'

TYPE_KO = {'hr': '인사', 'management': '경영', 'construction': '건설', 'rnd': '연구개발'}
TYPE_EN = {'hr': 'Human Resources', 'management': 'Management',
           'construction': 'Construction', 'rnd': 'R&D'}
# lib/dept_tile.dart 의 유형 4색
TYPE_COLOR = {'hr': '#846A6A', 'management': '#8A7A4F',
              'construction': '#6D7D62', 'rnd': '#7D6880'}
ORDER = ['hr', 'management', 'construction', 'rnd']

# 인쇄용 축약 효과 텍스트. lib/departments.dart 의 원문(규칙서 16–17쪽, 확장
# 룰북 2–3쪽 기준)을 뜻이 바뀌지 않게 줄인 것. 원문이 바뀌면 여기도 맞출 것.
# '_' = 줄바꿈 금지 공백(NBSP): 한 의미 단위(수치+단위, 명사구)는 한 줄에 유지하고
# 절 경계(→ 앞, 마침표·슬래시·'또는' 뒤)에서만 줄이 바뀌게 한다. '|' = 강제 줄바꿈.
SHORT = {
    1: '이_부서의_활성_직원_1명_파견|→_$8 또는 직원_이동_8회',
    2: '택1: 활성_직원_1명_파견 후 새_직원_1명을 로비에 / 직원_이동_4회',
    3: '활성_직원_1명_파견 →_회사_내_활성_직원_2명당 승점_1(올림). 파견_나간_직원은 제외',
    4: '조직_시 상품_큐브_2개 추가_지불. 이후 새_직원·복귀_직원을 두_로비_중 원하는_곳에 배치. '
       '활성_직원_없이도 적용되는 유일한_부서',
    5: '활성_직원_1명_파견|→_$8 또는 상품_큐브_3개',
    6: '상품_큐브_1~3개 지불 →_개당_$6',
    7: '상품_큐브_1~3개 지불 →_개당_$3_+_승점_1',
    8: '새_부서를 추가할_때마다 직원_1명(활성/비활성)을 즉시 새_부서로 이동_가능 (비활성으로_놓임)',
    9: '활성_직원_1명_파견 →_상품_큐브_1~2개_지불, 파견_지역에 프로젝트_1개 건설',
    10: '$3_+_상품_큐브_1~2개 지불 →_파견_없이 게임판_어디든 프로젝트_1개 건설',
    11: '상품_큐브_1~3개를 개당_$1에 구입',
    12: '활성_직원이 있는_동안 기부_비용_기준_$5_→_$3',
    13: '활성_직원_1명_파견 →_연구_점수_7',
    14: '이_부서의 활성_직원_1명당 연구_점수_4',
    15: '활성_직원_1명_파견 + 기부_비용_지불 →_다른_플레이어의 기부_디스크_위에 자기_디스크 놓기. '
        '같은_기부 2번_불가',
    16: '활성_직원이 있는_동안 운송수단_트랙_전진 연구_점수_비용_−1 (최소_1)',
    17: '이_부서의_활성_직원_1명_파견 →_회사의_인사_부서_1개당 (시작_부서_포함) 직원_1명을 '
        '원하는_칸으로 이동 (비활성_상태가_됨)',
    18: '지역_1곳 선택|→_그_지역의 자기_프로젝트_1개당_$2 또는 직원_이동_2회',
    19: '턴_시작_시 활성_직원이 있으면 그_턴_동안 회사_안에서 직원을 대각선으로도 이동_가능',
    20: '게임_종료_시 활성_직원이 있으면 회사_보드의 부서_없는_빈칸 1개당_승점_2',
    21: '이_부서의_활성_직원_1명_파견 →_회사의_경영_부서_1개당 (시작_부서_포함) $3',
    22: '지역_1곳 선택|→_그_지역의 자기_프로젝트_1개당_$2 또는 상품_큐브_1개',
    23: '활성_직원이 있는_동안 (활성화된_라운드 제외) 직원_활성화_시_택1: 명시_비용_+$2 내고 승점_+1 / '
        '비용_대신 $1만_내고 승점_−1 (승점_0_이하면 불가)',
    24: '게임_종료_시 활성_직원이 있으면 선택한_지역_1곳의 자기_프로젝트_1개당 승점_2',
    25: '이_부서의_활성_직원_1명_파견 →_회사의_건설_부서_1개당 (시작_부서_포함) 상품_큐브_1개',
    26: '지역_1곳 선택|→_그_지역의 자기_프로젝트_1개당_$2 또는 승점_1',
    27: '활성_직원이 있는_동안 프로젝트_종류와 다른_칸에도 건설_가능. 소도시 또는 일치하는_칸에 지으면 승점_1',
    28: '게임_종료_시 활성_직원이 있으면 대도시_연결_점수_+1 (최대_6). 연결_6점으로 마치면 보너스_승점_9',
    29: '이_부서의_활성_직원_1명_파견 →_회사의_연구개발_부서_1개당 (시작_부서_포함) 연구_점수_2',
    30: '지역_1곳 선택|→_그_지역의 자기_프로젝트_1개당_$2 또는 연구_점수_2',
    31: '활성_직원이 있는_동안 운송_수입을 자기_위치보다 낮은_단계로 선택_가능. '
        '운송수단_트랙 마지막_칸이 차_있어도 진입해 끝_보너스 획득',
    32: '게임_종료_시 활성_직원이 있으면 프로젝트를 가장_적게_지은 지역의 자기_프로젝트_1개당 승점_4',
}


def parse():
    text = SRC.read_text(encoding='utf-8')
    depts = []
    for block in re.findall(r'Department\((.*?)\n  \),', text, re.S):
        def field(name):
            m = re.search(name + r":\s*'(.*?)',\n", block, re.S)
            return m.group(1) if m else None
        number = int(re.search(r'number:\s*(\d+)', block).group(1))
        ko = field('ko')
        en = field('en')
        typ = re.search(r'type:\s*DeptType\.(\w+)', block).group(1)
        # 여러 줄로 이어 붙인 rule 문자열 합치기
        rule_m = re.search(r"rule:\s*((?:'.*?'\s*)+),", block, re.S)
        rule = ''.join(re.findall(r"'(.*?)'", rule_m.group(1), re.S))
        rule = rule.replace('\\$', '$')
        depts.append(dict(
            number=number, ko=ko, en=en, type=typ, rule=rule,
            ongoing='ongoing: true' in block,
            expansion='expansion: true' in block,
            endgame='endgame: true' in block,
        ))
    assert len(depts) == 32, len(depts)
    return depts


def b64(path, mime):
    return f'data:{mime};base64,' + base64.b64encode(path.read_bytes()).decode()


def main():
    depts = parse()
    by_num = {d['number']: d for d in depts}
    font_r = b64(ROOT / 'assets/fonts/SUIT-Regular.otf', 'font/otf')
    font_b = b64(ROOT / 'assets/fonts/SUIT-Bold.otf', 'font/otf')
    font_x = b64(ROOT / 'assets/fonts/SUIT-ExtraBold.otf', 'font/otf')

    # 4열(유형) × 9행(헤더 1 + 부서 8) 그리드. 행 높이는 그 행에서 가장 긴
    # 칸에 맞추고 남는 높이는 행마다 고르게 나눠 4열의 구분선이 정렬되게 한다.
    items = []
    for typ in ORDER:
        items.append(f'''
    <h2 style="--c:{TYPE_COLOR[typ]}"><span>{TYPE_KO[typ]}</span><small>{TYPE_EN[typ]}</small></h2>''')
    for row in range(8):
        for ti, typ in enumerate(ORDER):
            base_num = ti * 4 + row + 1
            d = by_num[base_num if row < 4 else base_num + 12]
            img = b64(ROOT / f"assets/departments/dept_{d['number']:02d}.webp",
                      'image/webp')
            tags = []
            if d['ongoing']:
                tags.append('<span class="tag">∞ 지속</span>')
            if d['endgame']:
                tags.append('<span class="tag">⚑ 종료</span>')
            cls = ['cell']
            if d['expansion']:
                cls.append('exp')
            if row == 4:
                cls.append('exp-first')
            if row == 7:
                cls.append('last')
            rule = (SHORT[d['number']].replace('_', '\u00a0').replace('|', '<br>')
                    .replace('→', '<span class="ar">→</span>'))
            items.append(f'''
    <div class="{' '.join(cls)}" style="--c:{TYPE_COLOR[typ]}">
      <img src="{img}" alt="">
      <div class="txt">
        <div class="name"><span class="num">{d['number']}</span>{d['ko']}{''.join(tags)}</div>
        <p class="rule">{rule}</p>
      </div>
    </div>''')

    html = f'''<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<title>카네기 부서 플레이어 에이드</title>
<style>
@font-face {{ font-family: SUIT; font-weight: 400; src: url({font_r}) format('opentype'); }}
@font-face {{ font-family: SUIT; font-weight: 700; src: url({font_b}) format('opentype'); }}
@font-face {{ font-family: SUIT; font-weight: 800; src: url({font_x}) format('opentype'); }}
@page {{ size: A4 landscape; margin: 0; }}
* {{ box-sizing: border-box; margin: 0; padding: 0; }}
html, body {{ background: #fff; }}
body {{
  font-family: SUIT, 'Apple SD Gothic Neo', 'Noto Sans KR', sans-serif;
  color: #353B3C; -webkit-print-color-adjust: exact; print-color-adjust: exact;
}}
.page {{
  width: 297mm; height: 210mm; padding: 5mm 6mm 5mm; overflow: hidden;
  display: flex; flex-direction: column;
}}
header {{
  display: flex; align-items: baseline; gap: 4mm; margin-bottom: 2mm;
  border-bottom: 0.5pt solid #C6C7C4; padding-bottom: 1.4mm;
}}
header h1 {{ font-size: 13pt; font-weight: 800; letter-spacing: -0.2pt; }}
header .sub {{ font-size: 7.5pt; color: #7A7477; font-weight: 700; letter-spacing: 1pt; }}
header .legend {{ margin-left: auto; font-size: 7.5pt; color: #5B5F60; display: flex; gap: 4mm; }}
header .legend b {{ font-weight: 700; color: #353B3C; }}
header .legend .sw {{ display: inline-block; width: 3mm; height: 2.2mm; background: #F2EFEF;
  border: 0.4pt solid #C6C7C4; vertical-align: -0.3mm; margin: 0 0.8mm 0 1.5mm; }}
.grid {{
  flex: 1; min-height: 0; display: grid; grid-template-columns: repeat(4, 1fr);
  grid-template-rows: auto repeat(8, auto); column-gap: 2mm; row-gap: 0;
}}
h2 {{
  background: var(--c); color: #fff; font-size: 9.5pt; font-weight: 800;
  padding: 1mm 2mm 0.9mm; display: flex; align-items: baseline; gap: 1.6mm;
  border-radius: 0.6mm 0.6mm 0 0;
}}
h2 small {{ font-size: 6.8pt; font-weight: 400; opacity: .8; letter-spacing: .3pt; }}
.cell {{
  display: flex; gap: 1.8mm; padding: 1mm 1.6mm 0.9mm 1.3mm; align-items: center;
  background: #fff; border: 0.5pt solid #C6C7C4; border-top: 0.4pt solid #DADCDB; border-bottom: 0;
}}
.cell.exp {{ background: #F2EFEF; }}
.cell.exp-first {{ border-top: 0.9pt solid var(--c); }}
.cell.last {{ border-bottom: 0.5pt solid #C6C7C4; }}
.cell img {{ height: 17mm; width: auto; flex: none; align-self: center; }}
.txt {{ flex: 1; min-width: 0; }}
.name {{ font-size: 9.2pt; font-weight: 800; line-height: 1.2; margin-bottom: 0.5mm; }}
.num {{
  display: inline-block; min-width: 4.4mm; padding: 0 0.8mm; margin-right: 1.3mm;
  background: var(--c); color: #fff; font-size: 7.2pt; text-align: center;
  border-radius: 0.5mm; line-height: 1.55; vertical-align: 0.2pt;
}}
.en {{ font-size: 6.4pt; font-weight: 400; color: #8B8589; margin-left: 1.2mm; }}
.tag {{
  display: inline-block; margin-left: 1.2mm; padding: 0 0.9mm; font-size: 6.2pt; font-weight: 700;
  color: var(--c); border: 0.4pt solid var(--c); border-radius: 0.5mm; line-height: 1.5;
  vertical-align: 0.4pt;
}}
.rule {{ font-size: 8.3pt; line-height: 1.32; word-break: keep-all; overflow-wrap: anywhere; }}
.rule .ar {{ font-family: 'Apple SD Gothic Neo', 'Noto Sans KR', sans-serif; padding: 0 0.3mm; }}
@media screen {{
  body {{ background: #DADCDB; padding: 10mm 0; }}
  .page {{ margin: 0 auto; box-shadow: 0 2mm 8mm rgba(0,0,0,.18); }}
}}
</style>
</head>
<body>
<div class="page">
  <header>
    <h1>카네기 부서 플레이어 에이드</h1>
    <span class="sub">CARNEGIE · DEPARTMENTS</span>
    <div class="legend">
      <span><b>기본</b> 1–16 · <b>확장</b> 17–32 <span class="sw"></span>음영 칸</span>
      <span><b>∞ 지속</b> 활성화된 직원이 있는 동안 계속 적용</span>
      <span><b>⚑ 종료</b> 게임 종료 시 득점</span>
    </div>
  </header>
  <div class="grid">{''.join(items)}</div>
</div>
</body>
</html>'''
    OUT.write_text(html, encoding='utf-8')
    print('wrote', OUT, f'{OUT.stat().st_size/1024:.0f} KB')


if __name__ == '__main__':
    main()

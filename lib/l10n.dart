import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 표시 언어 (한국어 / 영어). 첫 화면의 한영 스위치로 바꾼다.
enum AppLang { ko, en }

/// 현재 표시 언어. 앱 시작 시 [loadAppLang]으로 정해진다.
final appLang = ValueNotifier<AppLang>(AppLang.ko);

bool get isEn => appLang.value == AppLang.en;

/// 현재 언어에 맞는 문구를 고른다. 영문 문구는 영문 규칙서
/// (rulebook/Carnegie-rules-EN-WEB.pdf, Carnegie_rules_EXPANSION_v5.pdf)의
/// 용어를 따른다.
String tr(String ko, String en) => isEn ? en : ko;

const _prefsKey = 'app_lang';

/// 시작 언어: 한영 스위치로 저장한 값이 있으면 그 값, 없으면 기기(웹은
/// 브라우저) 언어가 한국어일 때 한국어, 그 외에는 영어.
///
/// 안드로이드는 기기 로캘이 main() 실행 뒤에 늦게 전달되므로, 저장값이
/// 없으면 사용자가 스위치를 누를 때까지 기기 언어 변경을 계속 따라간다.
Future<void> loadAppLang() async {
  AppLang? saved;
  try {
    final prefs = await SharedPreferences.getInstance();
    saved = AppLang.values.asNameMap()[prefs.getString(_prefsKey)];
  } catch (_) {
    // 저장소를 쓸 수 없는 환경(사생활 보호 모드 등)이면 기기 언어로 정한다.
  }
  if (saved != null) {
    _deviceFollower.stop();
    appLang.value = saved;
  } else {
    _deviceFollower.start();
  }
}

final _deviceFollower = _DeviceLangFollower();

/// 기기 로캘이 전달·변경될 때마다 표시 언어를 맞춘다 (저장값이 없을 때만).
class _DeviceLangFollower with WidgetsBindingObserver {
  bool _active = false;

  void start() {
    if (!_active) {
      _active = true;
      WidgetsBinding.instance.addObserver(this);
    }
    _sync();
  }

  void stop() {
    if (_active) {
      _active = false;
      WidgetsBinding.instance.removeObserver(this);
    }
  }

  void _sync() =>
      appLang.value = langOf(WidgetsBinding.instance.platformDispatcher.locale);

  @override
  void didChangeLocales(List<Locale>? locales) => _sync();
}

/// 기기 로캘에 맞는 기본 언어.
AppLang langOf(Locale locale) =>
    locale.languageCode == 'ko' ? AppLang.ko : AppLang.en;

/// 한영 스위치로 언어를 바꾸고, 다음 실행을 위해 기억해 둔다.
Future<void> setAppLang(AppLang lang) async {
  _deviceFollower.stop();
  appLang.value = lang;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, lang.name);
  } catch (_) {
    // 저장 실패 시에도 이번 실행의 언어 전환은 유지된다.
  }
}

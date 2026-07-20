import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  static const String languageKey = 'selected_language';

  LanguageProvider() {
    // Load the saved locale when the provider is initialized
    _loadLocale();
  }

  void setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    _locale = locale;
    notifyListeners();
    await _saveLocale(locale);
  }

  Future<void> _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString(languageKey);
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> _saveLocale(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageKey, locale.languageCode);
  }

  // List of supported locales
  static const supportedLocales = [
    Locale('en', ''), // English
    Locale('hi', ''), // Hindi
    Locale('bn', ''), // Bengali
    Locale('kn', ''), // Kannada
    Locale('mr', ''), // Marathi
    Locale('ml', ''), // Malayalam
    Locale('te', ''), // Telugu
    Locale('ta', ''), // Tamil
    Locale('pa', ''), // Punjabi
  ];

  // Mapping of locale codes to their full names
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'Hindi(हिन्दी)',
    'bn': 'Bengali(বাংলা)',
    'kn': 'Kannada(ಕನ್ನಡ)',
    'mr': 'Marathi(मराठी)',
    'ml': 'Malayalam(മലയാളം)',
    'te': 'Telugu(తెలుగు)',
    'ta': 'Tamil(தமிழ்)',
    'pa': 'Punjabi(ਪੰਜਾਬੀ)',
  };

  // Method to get the full language name
  String getLanguageName(Locale locale) {
    return languageNames[locale.languageCode] ?? locale.languageCode;
  }
}

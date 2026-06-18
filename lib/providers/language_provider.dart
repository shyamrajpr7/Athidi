import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isMalayalam = true;

  bool get isMalayalam => _isMalayalam;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _isMalayalam = prefs.getBool('isMalayalam') ?? true;
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    _isMalayalam = !_isMalayalam;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMalayalam', _isMalayalam);
    notifyListeners();
  }

  String t(String malayalamText, String englishText) {
    return _isMalayalam ? malayalamText : englishText;
  }
}

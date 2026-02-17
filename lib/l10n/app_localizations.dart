import 'package:flutter/material.dart';

/// App strings in English and Khmer.
/// Use [AppLocalizations.of(context).tr(key)] to get the translated string.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'messages': 'Messages',
      'connect': 'Connect',
      'settings': 'Settings',
      'channels': 'Channels',
      'directMessages': 'Direct Messages',
      'appearance': 'Appearance',
      'changeThemes': 'Change the themes',
      'darkMode': 'Dark Mode',
      'lightMode': 'Light Mode',
      'languages': 'Languages',
      'changeLanguages': 'Change languages',
      'english': 'English',
      'khmer': 'Khmer',
      'preferences': 'Preferences',
      'notifications': 'Notifications',
      'notificationsSubtitle': 'Receive message notifications',
      'locationSharing': 'Location Sharing',
      'locationSharingSubtitle': 'Share your location with mesh network',
      'about': 'About',
      'appVersion': 'App Version',
      'helpSupport': 'Help & Support',
    },
    'km': {
      'messages': 'សារ',
      'connect': 'ភ្ជាប់',
      'settings': 'ការកំណត់',
      'channels': 'ឆានែល',
      'directMessages': 'សារ',
      'appearance': 'រូបរាង',
      'changeThemes': 'ផ្លាស់ប្តូរផ្ទាំង',
      'darkMode': 'ផ្ទាំងងងឹត',
      'lightMode': 'ផ្ទាំងភ្លឺ',
      'languages': 'ភាសា',
      'changeLanguages': 'ផ្លាស់ប្តូរភាសា',
      'english': 'អង់គ្លេស',
      'khmer': 'ខ្មែរ',
      'preferences': 'ចំណូលចិត្ត',
      'notifications': 'ការជូនដំណឹង',
      'notificationsSubtitle': 'ទទួលការជូនដំណឹងសារ',
      'locationSharing': 'ការចែករងទីតាំង',
      'locationSharingSubtitle': 'ចែករងទីតាំងរបស់អ្នកជាមួយបណ្តាញ mesh',
      'about': 'អំពី',
      'appVersion': 'កំណែកម្មវិធី',
      'helpSupport': 'ជំនួយ និងគាំទ្រ',
    },
  };

  String tr(String key) {
    return _strings[locale.languageCode]?[key] ??
        _strings['en']?[key] ??
        key;
  }

  static AppLocalizations of(BuildContext context) {
    final data = context.dependOnInheritedWidgetOfExactType<_InheritedAppLocalizations>();
    assert(data != null, 'No AppLocalizations found in context');
    return data!.localizations;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    final data = context.dependOnInheritedWidgetOfExactType<_InheritedAppLocalizations>();
    return data?.localizations;
  }

  /// Wraps [child] so that [AppLocalizations.of(context)] works with [locale].
  static Widget wrap({required Locale locale, required Widget child}) {
    return _InheritedAppLocalizations(
      localizations: AppLocalizations(locale),
      child: child,
    );
  }
}

class _InheritedAppLocalizations extends InheritedWidget {
  const _InheritedAppLocalizations({
    required this.localizations,
    required super.child,
  });

  final AppLocalizations localizations;

  @override
  bool updateShouldNotify(_InheritedAppLocalizations old) =>
      localizations.locale != old.localizations.locale;
}

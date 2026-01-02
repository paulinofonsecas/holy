// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My App';

  @override
  String get welcome => 'Welcome';

  @override
  String hello(String name) {
    return 'Hello, $name';
  }

  @override
  String counter(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemMode => 'System Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSent => 'Notification sent';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get receiveNotifications => 'Receive push notifications';

  @override
  String get sendTestNotification => 'Send Test Notification';

  @override
  String get deviceToken => 'Device Token';

  @override
  String get loading => 'Loading...';

  @override
  String get notAvailable => 'Not available';

  @override
  String get profile => 'Profile';

  @override
  String get profileTitle => 'Profile';

  @override
  String get markedVerses => 'Marked Verses';

  @override
  String get markedVersesTitle => 'Marked Verses';

  @override
  String get searchHistory => 'Search History';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get themeColorTitle => 'Theme Color';

  @override
  String get searchHistoryTitle => 'Search History';

  @override
  String get noMarkedVerses => 'You haven\'t marked any verses yet.';

  @override
  String get noSearchHistory => 'Your search history is empty.';

  @override
  String get bible => 'Bible';

  @override
  String get search => 'Search';
}

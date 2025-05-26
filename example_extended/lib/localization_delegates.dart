import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AnyLocaleLocalizationsDelegate<T> extends LocalizationsDelegate<T> {
  AnyLocaleLocalizationsDelegate(this.decorated);

  final LocalizationsDelegate<T> decorated;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<T> load(Locale locale) => decorated.load(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<T> old) => false;
}

class WidgetsLocalizationsDelegate extends DefaultWidgetsLocalizations
    implements LocalizationsDelegate<WidgetsLocalizations> {
  WidgetsLocalizationsDelegate(this.textDirection);

  @override
  final TextDirection textDirection;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) => SynchronousFuture(this);

  @override
  bool shouldReload(covariant WidgetsLocalizationsDelegate old) => textDirection != old.textDirection;

  @override
  Type get type => WidgetsLocalizations;
}

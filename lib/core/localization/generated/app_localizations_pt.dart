// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Minha Aplicação';

  @override
  String get welcome => 'Bem-vindo';

  @override
  String hello(String name) {
    return 'Olá, $name';
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
      other: '$countString itens',
      one: '1 item',
      zero: 'Sem itens',
    );
    return '$_temp0';
  }

  @override
  String get signIn => 'Entrar';

  @override
  String get signUp => 'Registrar-se';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get forgotPassword => 'Esqueceu a sua senha?';

  @override
  String get settings => 'Configurações';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Modo Escuro';

  @override
  String get lightMode => 'Modo Claro';

  @override
  String get systemMode => 'Modo do Sistema';

  @override
  String get notifications => 'Notificações';

  @override
  String get notificationSent => 'Notificação enviada';

  @override
  String get enableNotifications => 'Ativar notificações';

  @override
  String get receiveNotifications => 'Receber notificações push';

  @override
  String get sendTestNotification => 'Enviar notificação de teste';

  @override
  String get deviceToken => 'Token do dispositivo';

  @override
  String get loading => 'Carregando...';

  @override
  String get notAvailable => 'Não disponível';
}

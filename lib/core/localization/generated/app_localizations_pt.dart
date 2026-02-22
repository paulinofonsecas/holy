// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Eu Sou';

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
      zero: 'Nenhum item',
    );
    return '$_temp0';
  }

  @override
  String get signIn => 'Entrar';

  @override
  String get signUp => 'Cadastrar';

  @override
  String get email => 'Email';

  @override
  String get password => 'Senha';

  @override
  String get forgotPassword => 'Esqueceu a senha?';

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
  String get enableNotifications => 'Ativar Notificações';

  @override
  String get receiveNotifications => 'Receber notificações push';

  @override
  String get sendTestNotification => 'Enviar Notificação de Teste';

  @override
  String get deviceToken => 'Token do Dispositivo';

  @override
  String get loading => 'Carregando...';

  @override
  String get notAvailable => 'Não disponível';

  @override
  String get profile => 'Perfil';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get markedVerses => 'Versículos Marcados';

  @override
  String get markedVersesTitle => 'Versículos Marcados';

  @override
  String get searchHistory => 'Histórico de Pesquisa';

  @override
  String get clearHistory => 'Limpar Histórico';

  @override
  String get themeColor => 'Cor do Tema';

  @override
  String get themeColorTitle => 'Cor do Tema';

  @override
  String get searchHistoryTitle => 'Histórico de Pesquisa';

  @override
  String get noMarkedVerses => 'Você ainda não marcou nenhum versículo.';

  @override
  String get noSearchHistory => 'Seu histórico de pesquisa está vazio.';

  @override
  String get bible => 'Bíblia';

  @override
  String get search => 'Pesquisar';

  @override
  String get deepUnderstandingChapter => 'Entendimento do Capítulo';
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/reading_plan.dart';
import '../../domain/entities/reading_plan_day.dart';
import '../../domain/entities/user_reading_progress.dart';

abstract class JourneyLocalDataSource {
  Future<List<ReadingPlan>> getAvailablePlans();
  Future<ReadingPlan> getPlanById(String id);
  Future<List<ReadingPlanDay>> getPlanDays(String planId);
  Future<ReadingPlanDay> getPlanDay(String planId, int day);

  Future<UserReadingProgress?> getUserProgress(String planId);
  Future<void> saveUserProgress(UserReadingProgress progress);
  Future<List<UserReadingProgress>> getAllUserProgresses();
}

class JourneyLocalDataSourceImpl implements JourneyLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _progressKeyPrefix = 'journey_progress_';

  JourneyLocalDataSourceImpl({required this.sharedPreferences});

  // ─── PLANS CATALOG ─────────────────────────────────────

  static const _plans = <ReadingPlan>[
    ReadingPlan(
      id: 'ansiedade_7d',
      title: 'Vencendo a Ansiedade',
      description:
          'Um plano de 7 dias com versículos, reflexões e orações para encontrar a paz de Deus em meio à ansiedade.',
      coverEmoji: '🕊️',
      durationDays: 7,
      isPremium: false,
      difficulty: 'Fácil',
      category: 'Emoções',
      tags: ['Ansiedade', 'Paz', 'Confiança'],
    ),
    ReadingPlan(
      id: 'fe_coragem_5d',
      title: 'Fé e Coragem',
      description:
          'Em 5 dias, descubra como a fé move montanhas e a coragem vem de Deus.',
      coverEmoji: '🦁',
      durationDays: 5,
      isPremium: false,
      difficulty: 'Fácil',
      category: 'Crescimento Espiritual',
      tags: ['Fé', 'Coragem', 'Fortaleza'],
    ),
    ReadingPlan(
      id: 'salmos_provebios_30d',
      title: 'Salmos e Provérbios',
      description:
          '30 dias mergulhando na sabedoria e louvor. Um Salmo e um Provérbio por dia.',
      coverEmoji: '🎵',
      durationDays: 30,
      isPremium: false,
      difficulty: 'Moderado',
      category: 'Devocionais',
      tags: ['Salmos', 'Provérbios', 'Sabedoria', 'Louvor'],
    ),
    ReadingPlan(
      id: 'identidade_cristo_7d',
      title: 'Minha Identidade em Cristo',
      description:
          'Descubra quem você é aos olhos de Deus. 7 dias transformadores sobre identidade e propósito.',
      coverEmoji: '👑',
      durationDays: 7,
      isPremium: false,
      difficulty: 'Fácil',
      category: 'Crescimento Espiritual',
      tags: ['Identidade', 'Propósito', 'Eu Sou'],
    ),
    ReadingPlan(
      id: 'evangelhos_90d',
      title: 'Os Evangelhos em 90 Dias',
      description:
          'Caminhe com Jesus através de Mateus, Marcos, Lucas e João em 90 dias de leitura.',
      coverEmoji: '✝️',
      durationDays: 90,
      isPremium: false,
      difficulty: 'Moderado',
      category: 'Bíblia Toda',
      tags: ['Evangelhos', 'Jesus', 'Novo Testamento'],
    ),
  ];

  // ─── PLAN DAYS SEED ─────────────────────────────────────

  static const Map<String, List<ReadingPlanDay>> _planDays = {
    'ansiedade_7d': [
      ReadingPlanDay(
        id: 'ansiedade_7d_1',
        planId: 'ansiedade_7d',
        day: 1,
        readings: ['Filipenses 4:6-7'],
        devotionalText:
            'Não andeis ansiosos de coisa alguma; em tudo, porém, sejam conhecidas, diante de Deus, as vossas petições, pela oração e pela súplica, com ações de graças.\n\nA ansiedade quer roubar a paz que Deus já te deu. Hoje, entregue cada preocupação a Ele. Ele não pede que você resolva tudo — Ele pede que confie.',
        prayer:
            'Senhor, eu entrego nas Tuas mãos tudo o que me preocupa. Guarda o meu coração e a minha mente em Cristo Jesus. Amém.',
      ),
      ReadingPlanDay(
        id: 'ansiedade_7d_2',
        planId: 'ansiedade_7d',
        day: 2,
        readings: ['Mateus 6:25-34'],
        devotionalText:
            'Observem as aves do céu: não semeiam, nem colhem, nem ajuntam em celeiros; contudo, vosso Pai celeste as alimenta.\n\nSe Deus cuida das aves e das flores, quanto mais cuidará de você? Hoje, escolha confiar na provisão do Pai.',
        prayer:
            'Pai, confio na Tua provisão. Ensina-me a viver o presente sem me prender ao amanhã. Amém.',
      ),
      ReadingPlanDay(
        id: 'ansiedade_7d_3',
        planId: 'ansiedade_7d',
        day: 3,
        readings: ['Salmos 23'],
        devotionalText:
            'O Senhor é o meu pastor e nada me faltará. Ele me faz repousar em pastos verdejantes.\n\nMesmo no vale da sombra da morte, Deus está ao seu lado. Você não está sozinho/a. O Pastor cuida de cada detalhe da sua vida.',
        prayer:
            'Senhor, sê o meu Pastor. Guia-me por caminhos de justiça e restaura a minha alma. Amém.',
      ),
      ReadingPlanDay(
        id: 'ansiedade_7d_4',
        planId: 'ansiedade_7d',
        day: 4,
        readings: ['Isaías 41:10'],
        devotionalText:
            'Não temas, porque eu sou contigo; não te assombres, porque eu sou o teu Deus; eu te fortaleço, e te ajudo, e te sustento.\n\nDeus não promete que a dificuldade vai desaparecer. Ele promete estar contigo nela. Isso muda tudo.',
        prayer:
            'Deus, eu sei que Tu estás comigo. Fortalece-me com a Tua destra fiel. Amém.',
      ),
      ReadingPlanDay(
        id: 'ansiedade_7d_5',
        planId: 'ansiedade_7d',
        day: 5,
        readings: ['1 Pedro 5:7'],
        devotionalText:
            'Lançando sobre ele toda a vossa ansiedade, porque ele tem cuidado de vós.\n\nLançar implica uma ação intencional. Não basta saber que Deus cuida — você precisa decidir entregar. Hoje, lance sobre Ele.',
        prayer:
            'Jesus, eu lanço sobre Ti cada medo, cada pensamento que me sufoca. Tu tens cuidado de mim. Amém.',
      ),
      ReadingPlanDay(
        id: 'ansiedade_7d_6',
        planId: 'ansiedade_7d',
        day: 6,
        readings: ['João 14:27'],
        devotionalText:
            'Deixo-vos a paz, a minha paz vos dou; não vo-la dou como o mundo a dá.\n\nA paz de Cristo não depende das circunstâncias. É uma paz sobrenatural. Peça e receba.',
        prayer:
            'Senhor Jesus, recebo a Tua paz. Que o meu coração não se turbe nem se atemorize. Amém.',
      ),
      ReadingPlanDay(
        id: 'ansiedade_7d_7',
        planId: 'ansiedade_7d',
        day: 7,
        readings: ['Romanos 8:28'],
        devotionalText:
            'Sabemos que todas as coisas cooperam para o bem daqueles que amam a Deus.\n\nVocê chegou ao fim deste plano. Lembre-se: Deus está no controle de tudo. Cada situação — mesmo a mais difícil — é usada por Ele para o seu bem. Parabéns pela jornada!',
        prayer:
            'Pai, obrigado por estes 7 dias. Que esta paz permaneça comigo todos os dias. Amém.',
      ),
    ],
    'fe_coragem_5d': [
      ReadingPlanDay(
        id: 'fe_coragem_5d_1',
        planId: 'fe_coragem_5d',
        day: 1,
        readings: ['Hebreus 11:1-6'],
        devotionalText:
            'Ora, a fé é a certeza de coisas que se esperam, a convicção de fatos que se não veem.\n\nFé não é ausência de dúvida — é escolher confiar mesmo sem ver. Hoje, dê o primeiro passo.',
        prayer:
            'Senhor, aumenta a minha fé. Quero crer no que ainda não vejo. Amém.',
      ),
      ReadingPlanDay(
        id: 'fe_coragem_5d_2',
        planId: 'fe_coragem_5d',
        day: 2,
        readings: ['Josué 1:9'],
        devotionalText:
            'Não se apavore, nem se desanime, pois o Senhor, o seu Deus, estará com você por onde quer que andar.\n\nCoragem não é a ausência de medo. É andar para frente mesmo com medo, sabendo que Deus vai na frente.',
        prayer:
            'Deus, caminha comigo. Onde eu for, Tu vais comigo. Dá-me coragem. Amém.',
      ),
      ReadingPlanDay(
        id: 'fe_coragem_5d_3',
        planId: 'fe_coragem_5d',
        day: 3,
        readings: ['Marcos 11:22-24'],
        devotionalText:
            'Jesus respondeu: Tende fé em Deus. Se alguém disser a este monte: levanta-te e lança-te no mar, e não duvidar, assim será.\n\nA fé não está no tamanho da sua capacidade, mas no tamanho do seu Deus.',
        prayer:
            'Jesus, eu confio em Ti. Ajuda-me a falar aos montes com fé. Amém.',
      ),
      ReadingPlanDay(
        id: 'fe_coragem_5d_4',
        planId: 'fe_coragem_5d',
        day: 4,
        readings: ['2 Timóteo 1:7'],
        devotionalText:
            'Porque Deus não nos deu espírito de covardia, mas de poder, de amor e de moderação.\n\nO espírito de medo não vem de Deus. O que vem Dele é poder, amor e domínio próprio.',
        prayer:
            'Pai, declaro que o espírito de medo não tem lugar em mim. Sou revestido de poder. Amém.',
      ),
      ReadingPlanDay(
        id: 'fe_coragem_5d_5',
        planId: 'fe_coragem_5d',
        day: 5,
        readings: ['Romanos 8:31-39'],
        devotionalText:
            'Se Deus é por nós, quem será contra nós?\n\nNada pode separar você do amor de Deus. Nem tribulação, nem angústia, nem perseguição. Você é mais do que vencedor. Parabéns por completar esta jornada!',
        prayer:
            'Senhor, obrigado por me mostrar que sou mais do que vencedor em Ti. Amém.',
      ),
    ],
    'identidade_cristo_7d': [
      ReadingPlanDay(
        id: 'identidade_cristo_7d_1',
        planId: 'identidade_cristo_7d',
        day: 1,
        readings: ['Efésios 2:10'],
        devotionalText:
            'Porque somos criação de Deus, criados em Cristo Jesus para boas obras.\n\nVocê não é um acidente. Deus criou você com propósito. Hoje, lembre-se: você é obra-prima Dele.',
        prayer:
            'Pai, obrigado por me criar com propósito. Ajuda-me a viver as boas obras que preparaste para mim. Amém.',
      ),
      ReadingPlanDay(
        id: 'identidade_cristo_7d_2',
        planId: 'identidade_cristo_7d',
        day: 2,
        readings: ['1 João 3:1'],
        devotionalText:
            'Vede que grande amor nos tem concedido o Pai, a ponto de sermos chamados filhos de Deus.\n\nFilho/filha de Deus — essa é a sua identidade primária. Nenhum rótulo do mundo pode substituir isso.',
        prayer: 'Pai, eu sou Teu filho/Tua filha. Isso é o bastante. Amém.',
      ),
      ReadingPlanDay(
        id: 'identidade_cristo_7d_3',
        planId: 'identidade_cristo_7d',
        day: 3,
        readings: ['2 Coríntios 5:17'],
        devotionalText:
            'Se alguém está em Cristo, é nova criatura. As coisas antigas já passaram; eis que se fizeram novas.\n\nO seu passado não define mais quem você é. Em Cristo, você é novo/nova.',
        prayer:
            'Jesus, obrigado por me fazer novo/nova. Ajuda-me a viver essa nova identidade. Amém.',
      ),
      ReadingPlanDay(
        id: 'identidade_cristo_7d_4',
        planId: 'identidade_cristo_7d',
        day: 4,
        readings: ['Gálatas 2:20'],
        devotionalText:
            'Já não sou eu quem vive, mas Cristo vive em mim.\n\nVocê é habitação do Espírito Santo. Dentro de você vive o poder que ressuscitou Jesus.',
        prayer:
            'Cristo, vive em mim. Que as pessoas vejam mais de Ti e menos de mim. Amém.',
      ),
      ReadingPlanDay(
        id: 'identidade_cristo_7d_5',
        planId: 'identidade_cristo_7d',
        day: 5,
        readings: ['Jeremias 29:11'],
        devotionalText:
            'Eu é que sei que pensamentos tenho a vosso respeito, pensamentos de paz e não de mal, para vos dar o fim que desejais.\n\nDeus tem planos de esperança para a sua vida. Confie no tempo e nos caminhos Dele.',
        prayer:
            'Senhor, confio nos Teus planos para mim. Dá-me paciência para esperar. Amém.',
      ),
      ReadingPlanDay(
        id: 'identidade_cristo_7d_6',
        planId: 'identidade_cristo_7d',
        day: 6,
        readings: ['Romanos 8:17'],
        devotionalText:
            'Se somos filhos, somos também herdeiros, herdeiros de Deus e co-herdeiros com Cristo.\n\nVocê não é um servo qualquer — é herdeiro. O Reino de Deus é a sua herança.',
        prayer:
            'Pai, obrigado pela herança eterna que me reservaste em Cristo. Amém.',
      ),
      ReadingPlanDay(
        id: 'identidade_cristo_7d_7',
        planId: 'identidade_cristo_7d',
        day: 7,
        readings: ['Salmos 139:13-16'],
        devotionalText:
            'Tu me teceste no ventre de minha mãe. Graças te dou, visto que por modo assombrosamente maravilhoso me formaste.\n\nDeus conhece cada detalhe de quem você é. Ele te formou com amor. Parabéns por concluir esta jornada de identidade!',
        prayer:
            'Pai, obrigado por quem eu sou em Ti. Vivo a minha identidade com alegria. Amém.',
      ),
    ],
    // Salmos e Evangelhos são planos longos — apenas os primeiros dias
    // são necessários para demonstrar o MVP.
    'salmos_provebios_30d': [
      ReadingPlanDay(
        id: 'sp_30d_1',
        planId: 'salmos_provebios_30d',
        day: 1,
        readings: ['Salmos 1', 'Provérbios 1:1-7'],
        devotionalText:
            'Bem-aventurado o homem que não anda no conselho dos ímpios.\n\nO primeiro Salmo é uma porta de entrada: mostra dois caminhos. Escolha hoje plantar suas raízes junto às águas da Palavra.',
        prayer:
            'Senhor, que eu seja como árvore plantada junto a ribeiros de águas. Amém.',
      ),
      ReadingPlanDay(
        id: 'sp_30d_2',
        planId: 'salmos_provebios_30d',
        day: 2,
        readings: ['Salmos 8', 'Provérbios 2:1-11'],
        devotionalText:
            'Que é o homem, para que dele te lembres? Fizeste-o pouco menor do que os anjos.\n\nDeus se importa com você. Você tem valor e dignidade dados por Ele.',
        prayer: 'Pai, obrigado por me dar honra e glória em Ti. Amém.',
      ),
      ReadingPlanDay(
        id: 'sp_30d_3',
        planId: 'salmos_provebios_30d',
        day: 3,
        readings: ['Salmos 19', 'Provérbios 3:1-8'],
        devotionalText:
            'Os céus proclamam a glória de Deus. Confia no Senhor de todo o teu coração.\n\nA criação fala de Deus. A sabedoria é confiá-Lo completamente.',
        prayer:
            'Senhor, em todos os meus caminhos, Te reconhecerei. Endireita as minhas veredas. Amém.',
      ),
    ],
    'evangelhos_90d': [
      ReadingPlanDay(
        id: 'ev_90d_1',
        planId: 'evangelhos_90d',
        day: 1,
        readings: ['Mateus 1–2'],
        devotionalText:
            'A genealogia de Jesus mostra que Deus trabalha através de gerações — incluindo pessoas imperfeitas. O nascimento de Cristo cumpre profecias seculares.\n\nDeus é fiel às Suas promessas.',
        prayer:
            'Senhor, obrigado por cumprir Tuas promessas. Ajuda-me a confiar na Tua fidelidade. Amém.',
      ),
      ReadingPlanDay(
        id: 'ev_90d_2',
        planId: 'evangelhos_90d',
        day: 2,
        readings: ['Mateus 3–4'],
        devotionalText:
            'O batismo de Jesus e a tentação no deserto. Jesus enfrentou as mesmas tentações que nós — e venceu pela Palavra.\n\nQual Palavra de Deus você vai usar hoje contra o inimigo?',
        prayer:
            'Jesus, ensina-me a vencer tentações com a Tua Palavra. Amém.',
      ),
      ReadingPlanDay(
        id: 'ev_90d_3',
        planId: 'evangelhos_90d',
        day: 3,
        readings: ['Mateus 5–6'],
        devotionalText:
            'O Sermão da Montanha: as bem-aventuranças, o sal e a luz, a oração do Pai Nosso.\n\nJesus redefine a felicidade. Não é sobre ter — é sobre ser.',
        prayer:
            'Pai nosso que estás nos céus, santificado seja o Teu nome. Amém.',
      ),
    ],
  };

  // ─── IMPLEMENTATIONS ──────────────────────────────────

  @override
  Future<List<ReadingPlan>> getAvailablePlans() async {
    return _plans;
  }

  @override
  Future<ReadingPlan> getPlanById(String id) async {
    return _plans.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Plano não encontrado: $id'),
    );
  }

  @override
  Future<List<ReadingPlanDay>> getPlanDays(String planId) async {
    return _planDays[planId] ?? [];
  }

  @override
  Future<ReadingPlanDay> getPlanDay(String planId, int day) async {
    final days = _planDays[planId] ?? [];
    return days.firstWhere(
      (d) => d.day == day,
      orElse: () => throw Exception('Dia $day não encontrado no plano $planId'),
    );
  }

  // ─── USER PROGRESS (SharedPreferences) ──────────────

  @override
  Future<UserReadingProgress?> getUserProgress(String planId) async {
    final jsonStr = sharedPreferences.getString('$_progressKeyPrefix$planId');
    if (jsonStr != null) {
      return UserReadingProgress.fromJson(jsonDecode(jsonStr));
    }
    return null;
  }

  @override
  Future<void> saveUserProgress(UserReadingProgress progress) async {
    final jsonStr = jsonEncode(progress.toJson());
    await sharedPreferences.setString(
      '$_progressKeyPrefix${progress.planId}',
      jsonStr,
    );
  }

  @override
  Future<List<UserReadingProgress>> getAllUserProgresses() async {
    final keys = sharedPreferences
        .getKeys()
        .where((k) => k.startsWith(_progressKeyPrefix));
    final progresses = <UserReadingProgress>[];
    for (final key in keys) {
      final jsonStr = sharedPreferences.getString(key);
      if (jsonStr != null) {
        progresses.add(UserReadingProgress.fromJson(jsonDecode(jsonStr)));
      }
    }
    return progresses;
  }
}

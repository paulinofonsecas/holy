# Configuração do Microsoft Clarity

Este projeto está integrado com o Microsoft Clarity para análise de comportamento de usuários.

## Pré-requisitos

1. Crie uma conta no [Microsoft Clarity](https://clarity.microsoft.com/)
2. Crie um novo projeto e obtenha o **Project ID**

## Configuração

### 1. Configurar Project ID

O Project ID do Clarity pode ser configurado de duas formas:

#### Opção 1: Variável de ambiente durante o build

```bash
flutter build apk --dart-define=CLARITY_PROJECT_ID=seu_project_id_aqui
flutter build ios --dart-define=CLARITY_PROJECT_ID=seu_project_id_aqui
```

#### Opção 2: Configuração web (index.html)

Para a versão web, edite o arquivo `web/index.html` e substitua `$CLARITY_PROJECT_ID` pelo seu Project ID real:

```html
<!-- Microsoft Clarity -->
<script type="text/javascript">
  (function (c, l, a, r, i, t, y) {
    c[a] =
      c[a] ||
      function () {
        (c[a].q = c[a].q || []).push(arguments);
      };
    t = l.createElement(r);
    t.async = 1;
    t.src = 'https://www.clarity.ms/tag/' + i;
    y = l.getElementsByTagName(r)[0];
    y.parentNode.insertBefore(t, y);
  })(window, document, 'clarity', 'script', 'SEU_PROJECT_ID');
</script>
```

### 2. Build do projeto

Para development:

```bash
flutter run --dart-define=CLARITY_PROJECT_ID=seu_project_id
```

Para production:

```bash
flutter build apk --release --dart-define=CLARITY_PROJECT_ID=seu_project_id
flutter build appbundle --release --dart-define=CLARITY_PROJECT_ID=seu_project_id
flutter build web --release --dart-define=CLARITY_PROJECT_ID=seu_project_id
```

## Recursos do Clarity

O Microsoft Clarity fornece:

- 📊 **Heatmaps**: Visualize onde os usuários clicam, tocam e rolam
- 🎥 **Session Recordings**: Assista gravações de sessões de usuários
- 📈 **Analytics**: Métricas de engajamento e comportamento
- 🐛 **Rage Clicks**: Identifique pontos de frustração do usuário
- 📱 **Mobile & Desktop**: Suporte completo para todas as plataformas

### Recursos Avançados

#### Custom Events

Você pode enviar eventos customizados para o Clarity para rastrear ações específicas do usuário:

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

// Enviar um evento customizado
await Clarity.sendCustomEvent('feature_used', {'feature_name': 'verse_search'});
```

#### Custom User ID

Defina um ID customizado para o usuário para rastrear sessões específicas:

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

// Definir ID customizado do usuário
await Clarity.setCustomUserId('user_12345');
```

#### Custom Tags

Adicione tags customizadas às sessões para facilitar a filtragem no dashboard:

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

// Adicionar uma tag
await Clarity.setCustomTag('user_type', 'premium');

// Adicionar múltiplas tags
await Clarity.setCustomTags({
  'app_version': '1.3.0',
  'subscription_status': 'active',
});
```

#### Pausar e Retomar Gravação

Você pode pausar e retomar a gravação de sessões conforme necessário:

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

// Pausar gravação (por exemplo, em telas sensíveis)
await Clarity.pause();

// Retomar gravação
await Clarity.resume();

// Verificar se está pausado
bool isPaused = await Clarity.isPaused();
```

#### Mascarar Widgets Sensíveis

Use `ClarityMask` para ocultar informações sensíveis das gravações:

```dart
import 'package:clarity_flutter/clarity_flutter.dart';

// Mascarar um widget específico
ClarityMask(
  child: TextField(
    decoration: InputDecoration(labelText: 'Senha'),
    obscureText: true,
  ),
)

// Desmascarar dentro de uma área mascarada
ClarityUnmask(
  child: Text('Este texto será visível'),
)
```

## Estrutura do código

A integração do Clarity está organizada da seguinte forma:

- **Configuração**: `lib/core/config/clarity_config.dart` - Gerencia o Project ID via variável de ambiente
- **Inicialização**: `lib/main.dart` - O app é envolvido com `ClarityWidget` após inicializar todos os serviços
- **Web**: Script no `web/index.html` - Para rastreamento adicional na versão web

### Implementação no código

O Clarity é inicializado usando a abordagem do `ClarityWidget` que envolve a aplicação:

```dart
// Em lib/main.dart
import 'package:clarity_flutter/clarity_flutter.dart' as clarity;
import 'package:eu_sou/core/config/clarity_config.dart';

// ... após inicializar todos os serviços ...

final clarityConfig = ClarityConfig.isEnabled
    ? clarity.ClarityConfig(
        projectId: ClarityConfig.projectId,
        logLevel: kDebugMode ? clarity.LogLevel.Info : clarity.LogLevel.None,
      )
    : null;

final app = SentryWidget(
  child: EntryPoint(
    // ... propriedades ...
  ),
);

runApp(
  clarityConfig != null
      ? clarity.ClarityWidget(
          app: app,
          clarityConfig: clarityConfig,
        )
      : app,
);
```

Esta abordagem garante que:

- O Clarity só é ativado quando um Project ID válido é fornecido
- Em modo de desenvolvimento (debug), logs são habilitados para facilitar troubleshooting
- Em produção, logs são desabilitados para otimizar performance
- A aplicação continua funcionando normalmente se o Clarity não estiver configurado

## Verificação

Após configurar e executar o app:

1. Acesse o dashboard do [Microsoft Clarity](https://clarity.microsoft.com/)
2. Abra seu projeto
3. Verifique se há sessões sendo registradas
4. Normalmente leva alguns minutos para os dados começarem a aparecer

## Troubleshooting

### O Clarity não está registrando dados (Mobile)

1. Verifique se o Project ID está correto
2. Verifique os logs do app em modo debug para ver se há mensagens do Clarity
3. Certifique-se de que o dispositivo está conectado à internet
4. As sessões levam de 30 minutos a 2 horas para aparecer completamente no dashboard

### O Clarity não está registrando dados (Web)

1. Verifique se o Project ID está correto no `web/index.html`
2. Abra o DevTools do navegador e verifique se há erros no console
3. Verifique se o script do Clarity está sendo carregado (aba Network)
4. Certifique-se de que o domínio está autorizado no painel do Clarity

### App não está iniciando quando o Clarity está habilitado

Este problema pode ocorrer se:

- O Project ID está em formato inválido
- Há conflito de dependências

Verifique os logs do app para identificar a causa específica.

### Logs de debug não aparecem em produção

Isso é esperado! Em builds de produção (release), o Clarity automaticamente desabilita os logs para otimizar performance. Os logs só aparecem em builds de debug.

## CI/CD

Para configurar o Clarity em pipelines de CI/CD, adicione a variável de ambiente `CLARITY_PROJECT_ID` aos seus secrets e use-a durante o build:

```yaml
# Exemplo GitHub Actions
- name: Build APK
  run: flutter build apk --release --dart-define=CLARITY_PROJECT_ID=${{ secrets.CLARITY_PROJECT_ID }}
```

## Privacidade

O Microsoft Clarity é uma ferramenta de analytics que respeita a privacidade:

- Não coleta informações pessoais identificáveis
- É gratuito e sem limites de uso
- Compatível com GDPR e outras regulamentações de privacidade

Consulte a [Política de Privacidade do Clarity](https://clarity.microsoft.com/privacy) para mais informações.

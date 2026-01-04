# 📱 Guia de Distribuição Firebase App Distribution

Este guia detalha como utilizar o sistema de automação para distribuir versões de teste do aplicativo **Eu Sou** via Firebase App Distribution.

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter as seguintes ferramentas instaladas:

1.  **Firebase CLI**:
    ```bash
    npm install -g firebase-tools
    ```
2.  **Autenticação**:
    ```bash
    firebase login
    ```
3.  **Flutter SDK**: Versão 3.38.5 ou superior.

---

## 🚀 Fluxos de Trabalho

### 1. Pipeline Completo (Recomendado)
O script de pipeline executa os testes, gera o build release e faz o upload para o Firebase em um único comando.

**No Windows (PowerShell):**
```powershell
.\scripts\build-and-distribute.ps1 -ReleaseNotes "Minhas notas" -Groups "testers"
```

**No Linux/macOS (Bash):**
```bash
./scripts/build-and-distribute.sh --release-notes "Minhas notas" --groups "testers"
```

**Via Makefile:**
```bash
make pipeline NOTES="Minhas notas" GROUPS="testers"
```

### 2. Apenas Distribuição
Se você já tem um APK gerado em `build/app/outputs/flutter-apk/app-release.apk`, pode apenas enviá-lo:

```powershell
.\scripts\distribute-apk.ps1 -ReleaseNotes "Correção rápida"
```

---

## 🛠️ Referência de Comandos

### Scripts PowerShell (`scripts/`)

| Script | Descrição | Parâmetros Principais |
| :--- | :--- | :--- |
| `distribute-apk.ps1` | Upload do APK para o Firebase | `-ReleaseNotes`, `-Groups`, `-DryRun`, `-VerboseOutput` |
| `build-and-distribute.ps1` | Pipeline completo | `-ReleaseNotes`, `-Groups`, `-SkipTests`, `-DryRun` |

### Scripts Bash (`scripts/`)

| Script | Descrição | Parâmetros Principais |
| :--- | :--- | :--- |
| `distribute-apk.sh` | Upload do APK para o Firebase | `--release-notes`, `--groups`, `--dry-run`, `--debug` |
| `build-and-distribute.sh` | Pipeline completo | `--release-notes`, `--groups`, `--skip-tests`, `--dry-run` |

### Makefile
O `Makefile` oferece atalhos convenientes:

*   `make pipeline`: Executa o pipeline completo.
*   `make distribute`: Faz o upload do APK existente.
*   `make build`: Gera o APK release.
*   `make test`: Executa todos os testes.

---

## 🤖 CI/CD (GitHub Actions)

A distribuição está integrada aos seguintes workflows:

1.  **`distribute.yml`**: Disparado em pushes para `main`, `develop` e `staging`. Também pode ser disparado manualmente.
2.  **`ci.yml`**: Realiza o upload para o Firebase após o build na branch `main`.
3.  **`release.yml`**: Ao criar uma tag de versão (`v*`), o APK é distribuído automaticamente para os testadores além de criar o Release no GitHub.

### Secrets Necessários
Para que o CI/CD funcione, os seguintes secrets devem estar configurados no repositório:
*   `FIREBASE_TOKEN`: Token de autenticação do Firebase.
*   `FIREBASE_APP_ID`: ID do aplicativo no Firebase (ex: `1:123456789:android:abc123def`).

---

## 🔍 Solução de Problemas

### Erro: "Firebase CLI not found"
Certifique-se de que o `firebase-tools` está instalado globalmente e o diretório de binários do npm está no seu PATH.

### Erro: "Authentication required"
Execute `firebase login` para renovar sua sessão local. No CI, verifique se o `FIREBASE_TOKEN` é válido.

### Erro: "APK not found"
O script tenta localizar o APK automaticamente. Se falhar, execute `flutter build apk --release` primeiro ou passe o caminho manualmente via `-ApkPath`.

### Como ver logs detalhados?
Use a flag `-VerboseOutput` (PowerShell) ou `--debug` (Bash) para ver os comandos exatos sendo executados.

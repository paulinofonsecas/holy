# 🚀 Distribuição Firebase - Guia Rápido

## ⚡ Uso Básico (Pipeline Completo)

A maneira mais fácil de rodar os testes, gerar o build e distribuir é usando o script de pipeline:

### Windows (PowerShell)
```powershell
.\scripts\build-and-distribute.ps1 -ReleaseNotes "Nova versão"
```

### Linux/macOS (Bash)
```bash
./scripts/build-and-distribute.sh --release-notes "Nova versão"
```

### Usando Makefile (Recomendado)
```bash
make pipeline NOTES="Nova versão"
```

## 🛠 Comandos Individuais

### 1. Apenas Distribuir (APK já existente)
```powershell
.\scripts\distribute-apk.ps1 -ReleaseNotes "Correção rápida"
```

### 2. Testar antes (Dry Run)
```powershell
.\scripts\distribute-apk.ps1 -DryRun
```

### 3. Com parâmetros personalizados
```powershell
.\scripts\distribute-apk.ps1 -ReleaseNotes "Correção de bugs v1.2.3" -Groups "qa-testers,beta-users"
```

### 4. Usando arquivo de release notes
```powershell
.\scripts\distribute-apk.ps1 -ReleaseNotes "@CHANGELOG.md"
```

## 🛠 Pré-requisitos

1. **Firebase CLI** (uma vez):
```bash
npm install -g firebase-tools
```

2. **Autenticar** (uma vez):
```bash
firebase login
```

## 📝 Parâmetros (distribute-apk.ps1)

| Parâmetro | Descrição | Padrão |
|-----------|-----------|--------|
| `-ApkPath` | Caminho do APK | Auto-detecta |
| `-AppId` | Firebase App ID | Extrai de firebase.json |
| `-ReleaseNotes` | Notas da versão | Vazio |
| `-Groups` | Grupos de testadores | "testers" |
| `-DryRun` | Testar sem executar | false |
| `-VerboseOutput` | Debug detalhado | false |

## 🎯 Exemplos Práticos

**Lançamento rápido via Makefile:**
```bash
make pipeline NOTES="Hotfix: corrige crash no login"
```

**Distribuição para beta:**
```powershell
.\scripts\distribute-apk.ps1 -Groups "beta-testers" -ReleaseNotes "Preview da feature XYZ"
```

**CI/CD (GitHub Actions):**
O workflow `.github/workflows/distribute.yml` já está configurado para rodar automaticamente em pushes para `main`, `develop` e `staging`.

## ❌ Resolução de Erros

| Exit Code | Erro | Solução |
|-----------|------|---------|
| 1 | Firebase CLI não instalado | `npm install -g firebase-tools` |
| 2 | Não autenticado | `firebase login` |
| 3 | APK não encontrado | `flutter build apk --release` |
| 4 | App ID inválido | Verificar firebase.json |
| 5 | Erro de upload/rede | Retry automático (3x) |

## ✅ Sucesso

Quando funcionar, você verá:
```
========================================
  Distribution Successful!
========================================

Duration: 45.2 seconds
Testers will receive notification shortly.
```

- [Documentação completa](../specs/012-firebase-apk-distribution/quickstart.md)
- [Contratos da API](../specs/012-firebase-apk-distribution/contracts/)

# 🚀 Distribuição Firebase - Guia Rápido

## ⚡ Uso Básico

### 1. Build + Distribuir
```powershell
# Build do APK
flutter build apk --release

# Distribuir automaticamente
.\scripts\distribute-apk.ps1
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

### 5. Com output verboso
```powershell
.\scripts\distribute-apk.ps1 -VerboseOutput
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

## 📝 Parâmetros

| Parâmetro | Descrição | Padrão |
|-----------|-----------|--------|
| `-ApkPath` | Caminho do APK | Auto-detecta |
| `-AppId` | Firebase App ID | Extrai de firebase.json |
| `-ReleaseNotes` | Notas da versão | Vazio |
| `-Groups` | Grupos de testadores | "internal-testers" |
| `-DryRun` | Testar sem executar | false |
| `-VerboseOutput` | Debug detalhado | false |

## 🎯 Exemplos Práticos

**Lançamento rápido:**
```powershell
flutter build apk --release && .\scripts\distribute-apk.ps1 -ReleaseNotes "Hotfix: corrige crash no login"
```

**Distribuição para beta:**
```powershell
.\scripts\distribute-apk.ps1 -Groups "beta-testers" -ReleaseNotes "Preview da feature XYZ"
```

**CI/CD (GitHub Actions):**
```yaml
- name: Distribute to Firebase
  env:
    FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
  run: |
    .\scripts\distribute-apk.ps1 -ReleaseNotes "Build ${{ github.run_number }}"
```

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

## 🔗 Mais Info

- [Documentação completa](../specs/012-firebase-apk-distribution/quickstart.md)
- [Contratos da API](../specs/012-firebase-apk-distribution/contracts/)

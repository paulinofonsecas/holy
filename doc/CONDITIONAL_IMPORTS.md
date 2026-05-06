# 🏗️ Importação Condicional - Padrão Aplicado

## Visão Geral

O projeto agora segue o padrão de **importação condicional em tempo de compilação** do Dart para resolver automaticamente qual implementação usar conforme a plataforma (Web vs Mobile).

---

## 📁 Estrutura Implementada

### 1️⃣ **ObjectBox Service** 

**Localização:** `lib/core/services/`

```
objectbox_service.dart          ← Façade com importação condicional
objectbox_service_mobile.dart   ← Implementação mobile (ObjectBox nativo)
objectbox_service_web.dart      ← Implementação web (stub)
```

**Como funciona:**

```dart
// objectbox_service.dart (Façade)
export 'objectbox_service_mobile.dart'
  if (dart.library.html) 'objectbox_service_web.dart';
```

👉 **Regra:**
- Se `dart.library.html` for **true** (Web) → usa `objectbox_service_web.dart`
- Caso contrário (Mobile/Desktop) → usa `objectbox_service_mobile.dart`

---

### 2️⃣ **Hive Vector Store**

**Localização:** `lib/features/deep_understanding/data/repositories/`

```
objectbox_vector_store_stub.dart   ← Façade com importação condicional
hive_vector_store_mobile.dart      ← Implementação mobile (Hive nativo)
hive_vector_store_web.dart         ← Implementação web (stub)
```

**Façade:**

```dart
// objectbox_vector_store_stub.dart
export 'hive_vector_store_mobile.dart'
  if (dart.library.html) 'hive_vector_store_web.dart';
```

---

## 🎯 Interfaces Abstradas

Ambas implementações implementam interfaces comuns para garantir compatibilidade:

### ObjectBoxService

```dart
abstract class ObjectBoxServiceBase {
  Store get store;
}
```

### HiveVectorStore

```dart
abstract interface class IVectorStore {
  Future<VerseEmbedding?> getEmbeddingByVerseId(String verseId);
  Future<void> saveEmbeddings(List<VerseEmbedding> embeddings);
  // ... outros métodos
}
```

---

## 🚀 Uso no Código

Em qualquer lugar do app, importe normalmente:

```dart
import 'package:eu_sou/core/services/objectbox_service.dart';
import 'package:eu_sou/features/deep_understanding/data/repositories/objectbox_vector_store_stub.dart';

// O Dart resolve automaticamente qual implementação usar! ✨
final service = ObjectBoxService();
final vectorStore = HiveVectorStore();
```

---

## ⚠️ Erros Comuns EVITADOS

### ❌ Antes (Errado)
```dart
import 'dart:html';  // ❌ Quebra em mobile

if (kIsWeb) {
  // ❌ Runtime check, não compile-time
}
```

### ✅ Agora (Correto)
```dart
// Compilação automática resolve qual arquivo usar
export 'service_mobile.dart'
  if (dart.library.html) 'service_web.dart';
```

---

## 🔄 Fluxo de Compilação

```
Código fonte
    ↓
Dart analisa: dart.library.html?
    ↓
SIM (Web)             NÃO (Mobile/Desktop)
    ↓                      ↓
service_web.dart     service_mobile.dart
    ↓                      ↓
Compilado para web   Compilado para mobile
```

---

## ✅ Benefícios

| Benefício | Descrição |
|-----------|-----------|
| **Type-Safe** | Erros de compilação ao invés de runtime |
| **Zero Runtime** | Sem `if (kIsWeb)` checks em todo o código |
| **Clean API** | Interface única para diferentes plataformas |
| **Otimizado** | Código não usado é eliminado na compilação |
| **Escalável** | Fácil adicionar novas plataformas |

---

## 📋 Checklist de Implementação

- [x] Criar interface abstrata (`ObjectBoxServiceBase`, `IVectorStore`)
- [x] Implementação mobile (`objectbox_service_mobile.dart`, `hive_vector_store_mobile.dart`)
- [x] Implementação web (`objectbox_service_web.dart`, `hive_vector_store_web.dart`)
- [x] Façade com importação condicional (`objectbox_service.dart`, `objectbox_vector_store_stub.dart`)
- [x] Remover arquivos antigos (objectbox_web.dart, objectbox_vector_store.dart, objectbox_vector_store_web.dart)
- [x] Validar compilação com `dart run build_runner build`

---

## 🔗 Referências

- [Dart Conditional Imports](https://dart.dev/guides/libraries/create-library-packages#conditional-imports)
- [Flutter Web Platform Detection](https://flutter.dev/docs/development/data-and-backend/json/json)


# Scripts de playground — bible_handler

Scripts utilitários para testar novas versões da Bíblia antes de publicá-las
no repositório de traduções.

## `playground_bible_versions.dart`

Testa o ciclo completo de uma versão (download → extração → parse → verificação):

```bash
cd packages/bible_handler

# Testa uma versão publicada no repositório biblias
dart run scripts/playground_bible_versions.dart KJA

# Mantém os arquivos extraídos em %TEMP% para inspeção manual
dart run scripts/playground_bible_versions.dart NVI --keep

# Testa uma versão ainda não publicada, apontando direto para o .zip
dart run scripts/playground_bible_versions.dart NOVA --url <url-do-zip>

# Ajuda
dart run scripts/playground_bible_versions.dart --help
```

### O que é verificado

| Verificação                                               | Severidade se falhar                  |
| --------------------------------------------------------- | ------------------------------------- |
| Download concluído sem erro                               | FAIL                                  |
| XML válido em cada arquivo `.usx` (validação individual)  | FAIL (WARN se só tags vazias `<>`)    |
| `metadata.xml` + 66 livros                                | FAIL/WARN                             |
| Abreviação nos metadados = versão solicitada              | WARN (detecta zip com outra tradução) |
| Ordem canônica dos livros (`book_order.dart`)             | FAIL                                  |
| ~1189 capítulos / ~31.100 versos                          | WARN                                  |
| Versos vazios                                             | FAIL                                  |
| Números de verso <= 0 ou duplicados                       | WARN                                  |
| Versos de amostra (Gn 1, Sl 23, Is 53, Mt 5, Jo 3, Ap 22) | WARN/FAIL                             |
| Busca por "Deus" e "espírito" (encoding/acentos)          | WARN                                  |

### Saída

O script imprime metadados, contagens, versos de amostra e um relatório final
com `PASS`/`WARN`/`FAIL`. O código de saída é `1` se houver qualquer `FAIL`,
o que permite usar o script em CI.

> Nota: os imports são feitos direto em `src/` (e não pelo barrel
> `bible_handler.dart`) porque o barrel depende de Flutter
> (`bible_cache_provider.dart`), o que impediria `dart run` puro.

## Bugs de dados conhecidos (nos zips do repositório `biblias`)

- **NTLH**: `2SA.usx` (linha 714) contém tags vazias `<>...</>` (nota de
  referência). O `UsxParser` agora sanitiza isso, mas o ideal é corrigir o
  arquivo no repositório de traduções.
- **NTLH / KJA**: `metadata.xml` com metadados trocados — a abreviação e o nome
  apontam para "ALBB" (Bíblia Albanesa) mesmo com o texto em português. O
  playground reporta isso como WARN. Corrigir o `metadata.xml` no zip.

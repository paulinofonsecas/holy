# Search Contract

## Events

### `FiltrarPorVersao`
Dispatched when the user selects a specific Bible version to filter search results.

```dart
class FiltrarPorVersao extends EventoBusca {
  final String? idVersao; // null means all versions
  FiltrarPorVersao(this.idVersao);
}
```

## States

### `BuscaCarregada`
Updated to include the current filter.

```dart
class BuscaCarregada extends EstadoBusca {
  final List<SearchResult> resultados;
  final List<Book> correspondenciasLivros;
  final String? filtroVersao;
  // ... existing fields
}
```

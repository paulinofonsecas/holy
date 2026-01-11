# Navigation Contract

## MainScaffold Interface
The `MainScaffold` is the root widget for the authenticated/main area of the app.

### Components
- **Body**: `IndexedStack` containing:
  - `BibliaPage`
  - `SearchScreen`
  - `ProfilePage`
- **BottomNavigationBar**:
  - Item 0: Icon `book`, Label `Bíblia`
  - Item 1: Icon `search`, Label `Pesquisa`
  - Item 2: Icon `person`, Label `Perfil`

## Navigation Cubit (Optional/Planned)
If global navigation control is needed:

```dart
class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);
  void setTab(int index) => emit(index);
}
```

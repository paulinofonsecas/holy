# Contract: Search BLoC Transformation

## New Event
### TransformarEmBuscaAvancada
- **Fields**: None (Uses current state data)
- **Description**: Triggered when the user selects "Pesquisa Avançada" from the menu.

## Behavior Change
- **State Transition**:
    - Current: Single search part `["deus criou"]`
    - Action: `TransformarEmBuscaAvancada`
    - New State: `["deus", "criou"]` with `JoinOperator.and` (or current global toggle).
- **Side Effect**: Must trigger `_realizarBusca` automatically after state update.

/// Explicit, observable view-state every screen renders from (constitution §1.3): a screen is a
/// pure function of one of these four states, never of ad-hoc booleans.
sealed class UiState<T> {
  const UiState();
}

class UiLoading<T> extends UiState<T> {
  const UiLoading();
}

class UiEmpty<T> extends UiState<T> {
  const UiEmpty();
}

class UiContent<T> extends UiState<T> {
  const UiContent(this.data);
  final T data;
}

class UiError<T> extends UiState<T> {
  const UiError(this.message);
  final String message;
}

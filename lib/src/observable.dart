class Observable<T> {
  final _observers = <T>{};

  Iterable<T> get observers => Set.unmodifiable(_observers);

  void addObserver(T observer) => _observers.add(observer);

  void removeObserver(T observer) => _observers.remove(observer);
}

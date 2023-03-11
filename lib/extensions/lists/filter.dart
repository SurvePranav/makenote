extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) test) =>
      map((items) => items.where(test).toList());
}

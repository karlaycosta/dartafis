import 'dart:collection';

class ReversedList<T> extends ListBase<T> {
  final List<T> inner;

  ReversedList(this.inner);
  
  @override
  int get length => inner.length;

  @override
  set length(int length) => inner.length = length;
  
  @override
  T operator [](int index) => inner[inner.length - index - 1];
  
  @override
  void operator []=(int index, T element) => inner[inner.length - index - 1] = element;

  @override
  void add(T element) => inner.insert(0, element);
}
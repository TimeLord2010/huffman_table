class HuffmanNode<T> {
  T? value;
  double frequency;

  HuffmanNode<T>? left;
  HuffmanNode<T>? right;

  HuffmanNode({
    required this.value,
    required this.frequency,
    this.left,
    this.right,
  });
}

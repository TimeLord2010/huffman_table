import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:huffman_table/src/data/models/huffman_node.dart';

class HuffmanTable<T> {
  HuffmanNode<T> root;
  Iterable<T>? data;

  HuffmanTable({
    required this.root,
    this.data,
  });

  factory HuffmanTable.fromIterable(Iterable<T> items) {
    // Calculate frequency of each item
    final frequencyMap = <T, double>{};
    for (var item in items) {
      frequencyMap[item] = (frequencyMap[item] ?? 0) + 1;
    }

    // Create a priority queue to build the Huffman tree
    final priorityQueue = PriorityQueue<HuffmanNode<T>>(
      (a, b) => a.frequency.compareTo(b.frequency),
    );

    // Add each item as a node to the priority queue
    frequencyMap.forEach((value, frequency) {
      priorityQueue.add(HuffmanNode<T>(
        value: value,
        frequency: frequency,
      ));
    });

    // Build the Huffman tree
    while (priorityQueue.length > 1) {
      final node1 = priorityQueue.removeFirst();
      final node2 = priorityQueue.removeFirst();

      final mergedNode = HuffmanNode<T>(
        value: null,
        frequency: node1.frequency + node2.frequency,
        left: node1,
        right: node2,
      );

      priorityQueue.add(mergedNode);
    }

    // The final node in the priority queue is the root of the Huffman tree
    final root = priorityQueue.removeFirst();

    return HuffmanTable(
      root: root,
      data: items,
    );
  }

  static List<T> decode<T>({
    required Uint8List bytes,
    required int bitLength,
    required Map<T, String> codeMap,
  }) {
    final reverseCodeMap = <String, T>{};

    // Create reverse map for decoding
    for (var entry in codeMap.entries) {
      reverseCodeMap[entry.value] = entry.key;
    }

    // Convert bytes to a bit string
    final bitBuffer = StringBuffer();
    for (var byte in bytes) {
      bitBuffer.write(byte.toRadixString(2).padLeft(8, '0'));
    }

    // Trim the bit string to the actual length used during encoding
    final bitString = bitBuffer.toString().substring(0, bitLength);

    // Decoding process
    final decoded = <T>[];
    var currentCode = StringBuffer();

    for (var bit in bitString.split('')) {
      currentCode.write(bit);
      if (reverseCodeMap.containsKey(currentCode.toString())) {
        decoded.add(reverseCodeMap[currentCode.toString()] as T);
        currentCode.clear();
      }
    }

    return decoded;
  }

  Map<T, String> generateCodeMap() {
    final codeMap = <T, String>{};
    void traverse(HuffmanNode<T> node, String code) {
      if (node.left == null && node.right == null && node.value != null) {
        codeMap[node.value!] = code;
        return;
      }
      if (node.left != null) traverse(node.left!, '${code}0');
      if (node.right != null) traverse(node.right!, '${code}1');
    }

    traverse(root, '');
    return codeMap;
  }

  Uint8List encode([Iterable<T>? data]) {
    data ??= this.data;
    if (data == null) {
      throw Exception('Data required');
    }

    final codeMap = generateCodeMap();
    final buffer = StringBuffer();

    for (var item in data) {
      buffer.write(codeMap[item]);
    }

    final bitString = buffer.toString();
    final byteLength = (bitString.length + 7) ~/ 8;
    final bytes = Uint8List(byteLength);

    for (int i = 0; i < bitString.length; i++) {
      if (bitString[i] == '1') {
        bytes[i >> 3] |= (128 >> (i % 8));
      }
    }

    return bytes;
  }
}

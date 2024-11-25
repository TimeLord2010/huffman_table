import 'package:huffman_table/huffman_table.dart';

void main() {
  var phase = 'a dead dad ceded a bad babe a beaded abaca bed';
  var table = HuffmanTable.fromIterable(phase.split(''));
  print(table.encode());
}

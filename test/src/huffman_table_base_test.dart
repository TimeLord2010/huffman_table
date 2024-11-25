import 'dart:typed_data';

import 'package:huffman_table/huffman_table.dart';
import 'package:test/test.dart';

void main() {
  test('huffman table base ...', () async {
    // MARK: Map check
    var phase = 'a dead dad ceded a bad babe a beaded abaca bed';
    var table = HuffmanTable.fromIterable(phase.split(''));
    var map = {
      ' ': '00',
      'd': '01',
      'a': '10',
      'e': '110',
      'c': '1110',
      'b': '1111',
    };
    expect(table.generateCodeMap(), map);

    // MARK: Encode check
    var expectedBitString = [
      '10000111',
      '01001000',
      '11001001',
      '11011001',
      '11001001',
      '00011111',
      '00100111',
      '11011111',
      '10001000',
      '11111101',
      '00111001',
      '00101111',
      '10111010',
      '00111111',
      '001',
    ].join();
    var encodedData = table.encode();
    var bitString = _uint8ListToBitString(encodedData);

    // Removing useless bits
    while (bitString.endsWith('0') &&
        bitString.length != expectedBitString.length) {
      bitString = bitString.substring(0, bitString.length - 1);
    }
    expect(bitString, expectedBitString);

    // MARK: Decode check
    var decodedData = HuffmanTable.decode(
      bytes: encodedData,
      bitLength: expectedBitString.length,
      codeMap: map,
    );
    var generatedPhase = decodedData.join('');
    expect(generatedPhase, phase);
  });
}

String _uint8ListToBitString(Uint8List bytes) {
  final buffer = StringBuffer();

  for (var byte in bytes) {
    // Convert each byte to its binary representation and ensure it's 8 bits long
    buffer.write(byte.toRadixString(2).padLeft(8, '0'));
  }

  // Maybe we should remove trailing zeros  here...
  return buffer.toString();
}

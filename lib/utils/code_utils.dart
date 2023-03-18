import 'dart:math';

/// Random extension for generate 6 digit otp code
extension RandomCode on Random {
  /// Characters for generate code
  static const alphabet = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'J',
    'K',
    'M',
    'N',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  ///Func for generate
  String getDigitCode(int lenght) {
    final random = Random.secure();
    final buffer = StringBuffer();

    for (var i = 0; i < lenght; i++) {
      buffer.write(alphabet[random.nextInt(alphabet.length)]);
    }
    return buffer.toString();
  }
}

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('villa loop and poster are bundled and readable', () async {
    final video = await rootBundle.load('assets/video/villa_garden_loop.mp4');
    final poster = await rootBundle.load(
      'assets/video/villa_garden_poster.jpg',
    );

    expect(video.lengthInBytes, greaterThan(500000));
    expect(poster.lengthInBytes, greaterThan(10000));

    final header = video.buffer.asUint8List(0, 12);
    expect(ascii.decode(header.sublist(4, 8)), 'ftyp');
    expect(header[8] | header[9] | header[10] | header[11], isNot(0));

    final jpeg = poster.buffer.asUint8List(0, 2);
    expect(jpeg, <int>[0xFF, 0xD8]);
  });
}

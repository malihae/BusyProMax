import 'package:busypro_max/models/activity.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every activity photo is bundled and readable', () async {
    for (final activity in activities) {
      final data = await rootBundle.load(activity.image);
      expect(
        data.lengthInBytes,
        greaterThan(0),
        reason: '${activity.image} should be bundled',
      );
    }
  });
}

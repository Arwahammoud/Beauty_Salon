import 'package:belle_beauty_salon/views/admin/admin_controller/admin_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Admin service validation', () {
    test('rejects non-positive price and duration', () {
      expect(AdminController.isValidServiceValues(price: 0, durationMins: 30), isFalse);
      expect(AdminController.isValidServiceValues(price: -1, durationMins: 30), isFalse);
      expect(AdminController.isValidServiceValues(price: 10, durationMins: 0), isFalse);
      expect(AdminController.isValidServiceValues(price: 10, durationMins: -5), isFalse);
    });

    test('accepts positive price and duration', () {
      expect(AdminController.isValidServiceValues(price: 25.5, durationMins: 45), isTrue);
      expect(AdminController.isValidServiceValues(price: 1, durationMins: 1), isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pln_converter/home/cubit/home_cubit.dart';

void main() {
  group('HomeState', () {
    HomeState createState() => const HomeState();

    test('constructor works properly', () {
      expect(() => createState(), returnsNormally);
    });

    test('supports value equality', () {
      expect(createState(), equals(createState()));
    });

    test('props are correct', () {
      expect(
        createState().props,
        equals(<Object?>[HomeTab.converter]),
      );
    });
  });
}

import 'package:settings_api/settings_api.dart';
import 'package:test/test.dart';

class TestSettingsApi extends SettingsApi {
  TestSettingsApi() : super();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  group('SettingsApi', () {
    test('can be constructed', () {
      expect(TestSettingsApi.new, returnsNormally);
    });
  });
}

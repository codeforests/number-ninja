import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/sync/token_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SecureTokenStore round-trips and clears (ACC-05)', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final store = SecureTokenStore();
    expect(await store.read(), isNull);
    await store.write('session');
    expect(await SecureTokenStore().read(), 'session');
    await store.clear();
    expect(await store.read(), isNull);
  });

  test('MemoryTokenStore round-trips', () async {
    final store = MemoryTokenStore();
    await store.write('x');
    expect(await store.read(), 'x');
    await store.clear();
    expect(store.value, isNull);
  });
}

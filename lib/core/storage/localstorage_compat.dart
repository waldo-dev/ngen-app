import 'package:localstorage/localstorage.dart' as ls;

final LocalStorage localStorage = LocalStorage('ngen_app');

Future<void> initLocalStorage() async {
  await ls.initLocalStorage();
}

/// Namespaced keys on top of [localstorage] 6.x single backing store.
class LocalStorage {
  LocalStorage(this.namespace);

  final String namespace;

  Future<bool> get ready async {
    await ls.initLocalStorage();
    return true;
  }

  dynamic getItem(String key) {
    return ls.localStorage.getItem(_scoped(key));
  }

  void setItem(String key, dynamic value) {
    ls.localStorage.setItem(_scoped(key), value is String ? value : value.toString());
  }

  void deleteItem(String key) {
    ls.localStorage.removeItem(_scoped(key));
  }

  String _scoped(String key) => '$namespace.$key';
}

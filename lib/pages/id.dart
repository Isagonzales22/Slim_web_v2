class UserSingleton {
  static final UserSingleton _singleton = UserSingleton._internal();
  late String userId;
  late String email;

  factory UserSingleton() {
    return _singleton;
  }

  UserSingleton._internal();
}

import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userViewModelProvider =
    Provider((ref) => UserViewModel(ref.watch(userRepositoryProvider)));

final getAllUsersProvider = StreamProvider((ref) {
  final users = ref.watch(userViewModelProvider);
  return users.getAllUsers();
});

final userDetailsProvider = StreamProvider.family<UserModel, String>(
    (ref, String id) => ref.watch(userViewModelProvider).getUserById(id));

final getSearchUsersProvider =
    StreamProvider.family<List<UserModel>, String>((ref, String query) {
  if (query.isEmpty) {
    return Stream.value([]);
  }
  return ref.watch(userViewModelProvider).getSearchUsers(query);
});

class UserViewModel {
  final UserRepository _userRepository;
  UserViewModel(this._userRepository);

  void changeUserStatus(bool status) async {
    await _userRepository.changeUserStatus(status);
  }

  Stream<List<UserModel>> getAllUsers() {
    return _userRepository
        .getAllUsers()
        .map((data) => data.map((e) => UserModel.fromMap(e.data())).toList());
  }

  Stream<UserModel> getUserById(String id) {
    final user = _userRepository.getUserById(id);
    return user.map((user) => UserModel.fromMap(user.data()!));
  }

  Stream<List<UserModel>> getSearchUsers(String query) {
    final users = _userRepository.getSearchUsers(query);
    return users.map(
        (data) => data.map((user) => UserModel.fromMap(user.data())).toList());
  }
}

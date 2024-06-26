import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_homework/network/user_item.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListException extends Equatable implements Exception {
  final String message;

  const ListException(this.message);

  @override
  List<Object?> get props => [message];
}

class ListModel extends ChangeNotifier {
  var isLoading = false;
  var users = <UserItem>[];

  Future loadUsers() async {
    if (isLoading) {
      return;
    }
    isLoading = true;
    notifyListeners();
    try {
      Dio dio = GetIt.I<Dio>();

      Response response = await dio.get('/users');

      List<dynamic> userDataList = response.data as List<dynamic>;
      users = userDataList
          .map((userJson) => UserItem(
                userJson['name'] ?? '',
                userJson['avatarUrl'] ?? '',
              ))
          .toList();

      notifyListeners();
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          throw ListException(e.response!.data['message']);
        }
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
